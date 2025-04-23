module GetNetCDFinf
    use Parameters
    use Structure 
    use netcdf 

    implicit none 

    contains 

    !:======================================================================
    ! Initialisation of the FEISTY model
    !:======================================================================
    ! Inputs:   
    ! Spinup_logical: logical, if true, the model will run for 100 years
    ! FEISTY: type(FEISTY_type), the main structure of the model
    ! diags: type(FEISTY_diag), the structure to store the diagnostics
    ! IC_tracers_Bio: type(Initial_conditions), the structure to store the initial conditions
    ! tracers: type(FEISTY_tracers), the structure to store the tracers
    ! Ntime: integer, the number of time steps
    ! Nlayer: integer, the number of layers
    ! Nlath: integer, the number of latitude
    ! Nlongh: integer, the number of longitude
    ! DataTemp: real(dp), the temperature data
    ! Datadet: real(dp), the detritus data
    ! Datadzm: real(dp), the mesozoo data
    ! DataZM: real(dp), the mesozoo data
    ! Datadzl: real(dp), the mesozoo data
    ! DataZL: real(dp), the mesozoo data
    ! Datazt: real(dp), the pseudo layer depth
    ! Datalat: real(dp), the latitude
    ! Datalon: real(dp), the longitude
    ! Datamax_depth: real(dp), the max depth
    !:======================================================================
    ! note: Some of  these variable do not have to be define before the function call
    !       they can just be defined in the function.
    !:======================================================================
    subroutine Init_FEISTY()                                                                                       
        real(dp), dimension(9, 9)           :: Datalat, Datalon
        real(dp), dimension(4, 4)           :: Datamax_depth
        real(dp), dimension(:), allocatable :: Datazt ! pseudo layer depth
        integer :: i, i_100m

        CALL Get_dim(dir_Temp)  ! Get the dimension of the data used to force the model
        CALL load_forcing_data ! Load the data used to force the model
        Call load_IC_fish ! Load the initial condition of the model
        ! 
        if (Spinup_logical) then 
            FEISTY%Ntime = FEISTY%Ntime * Year_2_Spinup
        end if

        ! Calculate the thickness of each layer 
        FEISTY%layer_thickness(1) =  FEISTY%zt(1)
        Do i = 2, 75
            FEISTY%layer_thickness(i) = FEISTY%zt(i) - FEISTY%zt(i-1) 
        end do 
        
        ! Calculate the index of the 100m layer: 
        i_100m = int(1)
        Do i = 1, 75
            if (FEISTY%zt(i) .le. 100.0) then 
                i_100m = i
            end if
        end do
        allocate(FEISTY%idx_100m(i_100m))
        FEISTY%idx_100m = (/(i, i=1, i_100m, 1)/)

        ! Allocate storage variables 
        CALL allocate_tracers
        CALL allocate_diags
        
        ! Individual Mass (g) geometric mean for each group s
        FEISTY%fish(Sf)%w = 10.0**((log10(0.001)+log10(0.5))/2)
        FEISTY%fish(Sp)%w = 10.0**((log10(0.001)+log10(0.5))/2)
        FEISTY%fish(Sd)%w = 10.0**((log10(0.001)+log10(0.5))/2)
        FEISTY%fish(Mf)%w = 10.0**((log10(0.5)+log10(250.0))/2) 
        FEISTY%fish(Mp)%w = 10.0**((log10(0.5)+log10(250.0))/2) 
        FEISTY%fish(Md)%w = 10.0**((log10(0.5)+log10(250.0))/2) 
        FEISTY%fish(Lp)%w = 10.0**((log10(250.0)+log10(125000.0))/2)
        FEISTY%fish(Ld)%w = 10.0**((log10(250.0)+log10(125000.0))/2)

    end subroutine Init_FEISTY

    !:====================================================================== 
    ! Get the dimension of the netCDF 4D gridfile
    !:======================================================================  
    subroutine Get_dim(dir)
        character(LEN=280), intent(in) :: dir
        character(LEN=250) :: xname, yname, zname, hname
        integer :: Ntime, Nlayer, Nlath, Nlongh
        integer  :: ncid, ierr
        integer, dimension(4) :: dim
        logical :: layer
        
        ! Open NetCDF: --------------------------------------------
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, "Error opening file: ", trim(dir)
            STOP
        end if

        dim(1) = 4
        dim(2) = 3
        dim(3) = 2
        dim(4) = 1

        ierr = nf90_inquire_dimension(ncid, dim(1), xname, Ntime)
        ierr = nf90_inquire_dimension(ncid, dim(2), yname, Nlayer)
        ierr = nf90_inquire_dimension(ncid, dim(3), zname, Nlath)
        ierr = nf90_inquire_dimension(ncid, dim(4), hname, Nlongh)
        
        !Close netCDF file
        ierr = nf90_close(ncid)
        
        ! print outputs: -------------------------------------------
        print *, "------------------------------------"
        print *, "1st dimension =", trim(xname), "; length = ", Ntime
        print *, "2nd dimension =", trim(yname), "; length = ", Nlayer
        print *, "3rd dimension =", trim(zname), "; length = ", Nlath
        print *, "4th dimension =", trim(hname), "; length = ", Nlongh
        print *, "------------------------------------"      

        print*, ""
        print*, "Save dimension to FEISTY type variables"
        ! Save the dimension of the forcing files in the FEISTY structure
        FEISTY%Ntime  = Ntime
        FEISTY%Nlayer = Nlayer
        FEISTY%Nlath  = Nlath
        FEISTY%Nlongh  = Nlongh
    end subroutine Get_dim

    !:====================================================================== 
    ! Load all the imput values to force the model
    !:======================================================================  
    subroutine load_forcing_data()
        real(dp), dimension(9, 9)   :: Datalat, Datalon
        real(dp), dimension(4, 4)   :: Datamax_depth
        real(dp), dimension(FEISTY%Nlayer) :: Datazt ! pseudo layer depth

        ! Get the input grid data to force the model: 
        ! Get physiological data:
        CALL readgrid4D(dir_Temp, var_Temp,  DataTemp)
        CALL readgrid4D(dir_zm, var_zm,      DataZM)
        CALL readgrid4D(dir_dzm, var_dzm,    Datadzm)
        CALL readgrid4D(dir_zl, var_zl,      DataZL)
        CALL readgrid4D(dir_dzl, var_dzl,    Datadzl)
        CALL readgrid3D(dir_det, var_det,    Datadet)

        
        ! Get data about the location 
        CALL readgrid1D(dir_zt, var_zt, Datazt)  ! pseudo layer depth 
        CALL readgrid2D(dir_lat, var_lat, Datalat) ! latitude 
        CALL readgrid2D(dir_lon, var_lon, Datalon) ! longitude
        CALL readgrid2D(dir_max_depth, var_max_depth, Datamax_depth) ! max depth   

        ! Convert depth grid into actual depth:
        ! var_zt is constant for every location and goes from 1 to  6212.405 m depth,
        ! we use maxdepth of the location 'var_max_depth' to rescale the depth. 
        FEISTY%zt = Datazt * Datamax_depth(1,1) / 6212.405

        FEISTY%lat = Datalat ! latitude 
        FEISTY%lon = Datalon ! longitude
        FEISTY%max_depth = Datamax_depth(1,1) ! max depth
    end subroutine load_forcing_data

    !:====================================================================== 
    ! Load all the Spinup Initial condition to force the FEISTY
    !:======================================================================  
    subroutine load_IC_fish()
        integer :: i

        if (Spinup_logical .eqv. .false.) then 
            do i = 1, nDeriv
                allocate(IC_tracers_Bio(i)%IniBio(FEISTY%Nlath, FEISTY%Nlongh))
            end do 
            CALL readgrid2D(dir_IniSf, 'Sf', IC_tracers_Bio(1)%IniBio)
            CALL readgrid2D(dir_IniSp, 'Sp', IC_tracers_Bio(2)%IniBio)
            CALL readgrid2D(dir_IniSd, 'Sd', IC_tracers_Bio(3)%IniBio)
            CALL readgrid2D(dir_IniMf, 'Mf', IC_tracers_Bio(4)%IniBio)
            CALL readgrid2D(dir_IniMp, 'Mp', IC_tracers_Bio(5)%IniBio)
            CALL readgrid2D(dir_IniMd, 'Md', IC_tracers_Bio(6)%IniBio)
            CALL readgrid2D(dir_IniLp, 'Lp', IC_tracers_Bio(7)%IniBio)
            CALL readgrid2D(dir_IniLd, 'Ld', IC_tracers_Bio(8)%IniBio)
            CALL readgrid2D(dir_IniBE, 'BE', IC_tracers_Bio(9)%IniBio)
        end if
    end subroutine load_IC_fish

    !:====================================================================== 
    ! Write the output in netCDF files
    !:======================================================================     
    subroutine write_output_netcdf()
        integer :: i

        IF (Spinup_logical) THEN
            DO i = 1, nDeriv
                CALL write_nc_file3D(Dir_IC(i), tracers_name(i), tracers(i)%Bio(FEISTY%Ntime, 1:FEISTY%Nlath, 1:FEISTY%Nlongh))
            END DO
    
            IF (Spinup_Time_Serie) THEN
                DO i = 1, nDeriv
                    CALL write_nc_file4D("../output/netcdf/" // TRIM(coupling) // "/" // TRIM(loc) // "/" // TRIM(exp) //&
                        "/COBALT_" // TRIM(coupling) // "_" // TRIM(loc) // "_" // TRIM(exp) // &
                        "_" // TRIM(tracers_name(i)) // "_bio_Spinup_Time_Serie.nc", &
                        TRIM(tracers_name(i)), tracers(i)%Bio)
                END DO
            END IF
    
            IF (Initial_Condition_generic_FEISTY) THEN
                CALL FEISTY_Save_IC()
            END IF
        ELSE
            ! Write each biomass variable to a separate NetCDF file
            DO i = 1, nDeriv
                ! print *, tracers_name(i)
                ! print *, tracers(i)%Bio
                CALL write_nc_file4D("../output/netcdf/" // TRIM(coupling) // "/" // TRIM(loc) // "/" // TRIM(exp) //&
                    "/COBALT_" // TRIM(coupling) // "_" // TRIM(loc) // "_" // TRIM(exp) // &
                    "_" // TRIM(tracers_name(i)) // "_bio.nc", &
                    TRIM(tracers_name(i)), tracers(i)%Bio)
            END DO
            ! Write eooplankton overconsumption to a separate NetCDF file
            DO i = 1, nMesoZoo
                CALL write_nc_file4D("../output/netcdf/" // TRIM(coupling) // "/" // TRIM(loc) // "/" // TRIM(exp) //&
                "/COBALT_" // TRIM(coupling) // "_" // TRIM(loc) // "_" // TRIM(exp) // &
                "_" // TRIM(Meso_diag_name(i)) // ".nc", &
                TRIM(Meso_diag_name(i)), diags%mesozoo(i)%Zcon_VS_dZ)
            END DO

            ! Write diagnostic variables to a separate NetCDF file
            CALL FEISTY_Save_diag()
        END IF
    END SUBROUTINE write_output_netcdf

    subroutine write_nc_file4D(filename, varname, var)
        character(*), intent(in) :: filename, varname
        real(dp), dimension(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh), intent(in) :: var
        integer :: ncid, dimids(4), varid
        integer :: status 

        ! Create the NetCDF file
        status = nf90_create(filename, NF90_CLOBBER, ncid)
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *, "Error creating file: ", trim(filename)
            stop
        end if
        
        ! Define the dimensions
        status = nf90_def_dim(ncid, 'Time'  , FEISTY%Ntime  , dimids(1))
        status = nf90_def_dim(ncid, 'Layer' , FEISTY%Nlayer , dimids(2))
        status = nf90_def_dim(ncid, 'Lath'  , FEISTY%Nlath  , dimids(3))
        status = nf90_def_dim(ncid, 'Longh' , FEISTY%Nlongh , dimids(4))

        ! Define the variable
        status = nf90_def_var(ncid, varname, NF90_REAL, dimids([1,3,4]), varid)
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *, "Error def var: ", trim(varname), " in: ", trim(filename)
            stop
        end if

       ! add a unit attribute 
        status = nf90_put_att(ncid, varid, 'units', 'gWW m-2')
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *, "nf90_put_att: ", trim(varname), " in: ",  trim(filename)
            stop
        end if

        ! End the definitions mode
        status = nf90_enddef(ncid)
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *, "Error endingdef mode: ", trim(filename)
            stop
        end if

        ! Write the variable data
        status = nf90_put_var(ncid, varid, var)
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *, "nf90_put_var: ", trim(varname), " in: ",  trim(filename)
            stop
        else 
            print *, "var written: ", trim(varname), " in: ",  trim(filename)
        end if

        ! Close the file
        status = nf90_close(ncid)
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *, "nf90_close: ", trim(varname), " in: ",  trim(filename)
            stop
        else 
            print *, "File closed: ", trim(filename)
        end if


    end subroutine write_nc_file4D

    subroutine write_nc_file3D(filename, varname, var)
        character(*), intent(in) :: filename, varname
        real(dp), dimension(FEISTY%Nlath, FEISTY%Nlongh), intent(in) :: var
        integer :: ncid, dimids(3), varid
        integer :: status

        ! Create the NetCDF file
        status = nf90_create(filename, NF90_CLOBBER, ncid)
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *, "Error creating file: ", trim(filename)
            stop
        end if
        
        ! Define the dimensions
        status = nf90_def_dim(ncid, 'Layer' , FEISTY%Nlayer , dimids(1))
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *, "Error def_dim: ", 'Layer'
            stop
        end if
        status = nf90_def_dim(ncid, 'Lath'  , FEISTY%Nlath  , dimids(2))
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *,  "Error def_dim: ", 'Lath'
            stop
        end if
        status = nf90_def_dim(ncid, 'Longh' , FEISTY%Nlongh , dimids(3))
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *,  "Error def_dim: ", 'Longh'
            stop
        end if

        ! Define the variable
        status = nf90_def_var(ncid, varname, NF90_REAL, dimids(2:3), varid)
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *,  "Error nf90_def_var: ", trim(varname), " in: ", trim(filename)
            stop
        end if

        ! add a unit attribute 
        status = nf90_put_att(ncid, varid, 'units', 'gWW m-2')
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *,  "Error nf90_put_att: ", trim(varname), " in: ", trim(filename)
            stop
        end if

        ! End the definitions mode
        status = nf90_enddef(ncid)
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *,  "Error nf90_enddef: ", trim(varname), " in: ", trim(filename)
            stop
        end if
        
        ! Write the variable data
        status = nf90_put_var(ncid, varid, var)
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *,  "Error nf90_put_var: ", trim(varname), " in: ", trim(filename)
            stop
        end if
        
        ! Close the file
        status = nf90_close(ncid)
        if (status /= NF90_NOERR) then
            print *, nf90_strerror(status)
            print *,  "Error nf90_close: ", " in: ", trim(filename)
            stop
        end if
    end subroutine write_nc_file3D


    !:====================================================================== 
    ! Get the input values for the given lat long and time 
    ! integrate all over depth and store them in the FEISTY structure
    !:======================================================================  
    subroutine Get_Environmental_data()
        ! Integrate all over depth and store them in the FEISTY structure
        FEISTY%Tp = sum(DataTemp(FEISTY%ilongh, FEISTY%ilath, FEISTY%idx_100m, FEISTY%iDay)) / size(FEISTY%idx_100m)
        FEISTY%Tb = DataTemp(FEISTY%ilongh, FEISTY%ilath, FEISTY%Nlayer, FEISTY%iDay)
        FEISTY%mesozoo(1)%B  = sum(DataZM(FEISTY%ilongh, FEISTY%ilath, FEISTY%idx_100m, FEISTY%iDay) & 
                                    * FEISTY%layer_thickness(FEISTY%idx_100m)) * convers_zm
        FEISTY%mesozoo(2)%B  = sum(DataZL(FEISTY%ilongh, FEISTY%ilath, FEISTY%idx_100m, FEISTY%iDay) &
                                    * FEISTY%layer_thickness(FEISTY%idx_100m)) * convers_zm
        FEISTY%mesozoo(1)%dz = sum(Datadzm(FEISTY%ilongh, FEISTY%ilath, FEISTY%idx_100m, FEISTY%iDay)) * convers_dZm
        FEISTY%mesozoo(2)%dz = sum(Datadzl(FEISTY%ilongh, FEISTY%ilath, FEISTY%idx_100m, FEISTY%iDay)) * convers_dZm
        FEISTY%det = Datadet(FEISTY%ilongh, FEISTY%ilath, FEISTY%iDay) * convers_det
    end subroutine Get_Environmental_data


    subroutine readgrid4D(dir, varname, values)
        character(LEN=280), intent(in) :: dir, varname
        real(dp), dimension(:, :, :, :), allocatable, intent(inout) :: values
        integer :: ierr, ncid, varid
    
        allocate(values(FEISTY%Nlongh, FEISTY%Nlath, FEISTY%Nlayer, FEISTY%Ntime))
    
        ! Open NetCDF file
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, nf90_strerror(ierr)
            print *, "Error opening file: ", trim(dir)
            stop
        end if
    
        ! Get variable ID
        ierr = nf90_inq_varid(ncid, varname, varid)
        if (ierr /= NF90_NOERR) then
            print *, "Error nf90_inquire_variable: ", nf90_strerror(ierr)
            stop
        end if
    
        ! Get values of the variable
        ierr = nf90_get_var(ncid, varid, values)
        if (ierr /= NF90_NOERR) then
            print *, "Error nf90_get_var: ", nf90_strerror(ierr)
            stop
        end if
    
        ! Close the NetCDF file
        ierr = nf90_close(ncid)
    
        print *, trim(varname), " loaded"
        ! print *, "dir : ", trim(dir)
    end subroutine readgrid4D

    subroutine readgrid3D(dir, varname, values)
        character(LEN=*), intent(in) :: dir, varname
        real(dp), dimension(:, :, :), allocatable, intent(inout) :: values
        integer :: ierr, ncid, varid
    
        allocate(values(FEISTY%Nlongh, FEISTY%Nlath, FEISTY%Ntime))
    
        ! Open NetCDF file
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, nf90_strerror(ierr)
            print *, "Error opening file: ", trim(dir)
            stop
        end if
    
        ! Get variable ID
        ierr = nf90_inq_varid(ncid, varname, varid)
        if (ierr /= NF90_NOERR) then
            print *, "Error nf90_inquire_variable: ", nf90_strerror(ierr)
            stop
        end if
    
        ! Get values of the variable
        ierr = nf90_get_var(ncid, varid, values)
        if (ierr /= NF90_NOERR) then
            print *, "Error nf90_get_var: ", nf90_strerror(ierr)
            stop
        end if
    
        print *, "Initial condition ", trim(varname), " loaded"

        ! Close the NetCDF file
        ierr = nf90_close(ncid)
    end subroutine readgrid3D

    subroutine readgrid2D(dir, varname, values)
        character(LEN=*), intent(in) :: dir, varname
        real(dp), dimension(:, :), intent(inout) :: values
        integer :: ierr, ncid, varid
    
        ! Open NetCDF file
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, nf90_strerror(ierr)
            print *, "Error opening file: ", trim(dir)
            stop
        end if
    
        ! Get variable ID
        ierr = nf90_inq_varid(ncid, varname, varid)
        if (ierr /= NF90_NOERR) then
            print *, "Error in ", trim(varname), " nf90_inquire_variable: ", nf90_strerror(ierr)
            stop
        end if
    
        ! Get values of the variable
        ierr = nf90_get_var(ncid, varid, values)
        if (ierr /= NF90_NOERR) then
            print *, "Error in ", trim(varname), " nf90_get_var: ", nf90_strerror(ierr)
            stop
        end if
    
        print *, "Initial condition ", trim(varname), " loaded"
    
        ! Close the NetCDF file
        ierr = nf90_close(ncid)
    end subroutine readgrid2D

    subroutine readgrid1D(dir, varname, values)
        character(LEN=*), intent(in) :: dir, varname
        real(dp), dimension(:), intent(inout) :: values 
        integer :: ierr, ncid, varid
    
        ! Open NetCDF file
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, nf90_strerror(ierr)
            print *, "Error opening file: ", trim(dir)
            stop
        end if
    
        ! Get variable ID
        ierr = nf90_inq_varid(ncid, varname, varid)
        if (ierr /= NF90_NOERR) then
            print *, "Error in ", trim(varname), " nf90_inquire_variable: ", nf90_strerror(ierr)
            stop
        end if
    
        ! Get values of the variable
        ierr = nf90_get_var(ncid, varid, values)
        if (ierr /= NF90_NOERR) then
            print *, "Error in ", trim(varname), " nf90_get_var: ", nf90_strerror(ierr)
            stop
        end if
    
        ! Close the NetCDF file
        ierr = nf90_close(ncid)
    end subroutine readgrid1D

    subroutine FEISTY_Save_IC()
        character(LEN=280) :: filename
        integer(4) :: ncid, dimids(4)
        integer :: i
        real(dp), dimension(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh) :: hp_ingest_nmdz
    
        filename = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // "/" // trim(exp) // &
                    "/FEISTY_2D_2023_10_spinup_subset.nc"
        call init_tracer_nc(filename, ncid, dimids)
    
        do i = 1, nDeriv
            call add_tracer_nc(ncid, dimids, trim(tracers_name(i)) // "_B", tracers_long_name(i), tracers(i)%Bio)
        end do
    
        ! Add hp_ingest_nmdz and hp_ingest_nlgz for COBALT initialization
        hp_ingest_nmdz(:,:,:) = 0.0_dp
        call add_tracer_nc(ncid, dimids, "hp_ingest_nmdz", "fish ingestion of medium zooplankton", hp_ingest_nmdz)
        call add_tracer_nc(ncid, dimids, "hp_ingest_nlgz", "fish ingestion of large zooplankton", hp_ingest_nmdz)
    
        call end_tracer_nc(ncid)
        print*, "COBALT IC saved:", filename
    end subroutine FEISTY_Save_IC

    subroutine init_tracer_nc(filename, ncid, dimids)
        character(LEN = 280), intent(in)        :: filename 
        integer, intent(inout)                  :: ncid, dimids(4)
        integer :: status
        integer :: varid_time, varid_layer, varid_lath, varid_longh
        integer :: i
 
        print*, "Creating NetCDF file for tracers: ", filename

        ! Create the NetCDF file
        status = nf90_create(filename, NF90_CLOBBER, ncid)
        if (status /= NF90_NOERR) then
            print *, "Error creating " , trim(filename), " in init_tracer_nc"
            print *, trim(nf90_strerror(status))
            STOP
        end if

        ! Define the dimensions
        status = nf90_def_dim(ncid, 'Time' , NF90_UNLIMITED,  dimids(4))
        if (status /= NF90_NOERR) then
            print *, trim(nf90_strerror(status))
            STOP
        end if
        status = nf90_def_dim(ncid, 'Layer', FEISTY%Nlayer, dimids(3))
        status = nf90_def_dim(ncid, 'lath' , FEISTY%Nlath , dimids(2))
        status = nf90_def_dim(ncid, 'lonh' , FEISTY%Nlongh, dimids(1))

        !! Define variables for each dimension: --------------------------------------------------------------
        ! Time: 
            ! Define the variable
            status = nf90_def_var(ncid, 'Time', NF90_doUBLE, dimids(4), varid_time)
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_time, 'long_name', 'Time')
            status = nf90_put_att(ncid, varid_time, 'Standard_name', 'time')
            status = nf90_put_att(ncid, varid_time, 'units', 'days')
            status = nf90_put_att(ncid, varid_time, 'calendar', 'proleptic_gregorian')
            status = nf90_put_att(ncid, varid_time, 'axis', "T")
            status = nf90_put_att(ncid, varid_time, '_FillValue', -9999.0_dp)

        ! Layer:
            ! Define the variable
            status = nf90_def_var(ncid, 'Layer', NF90_doUBLE, dimids(3), varid_layer)
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_layer, 'long_name', 'Layer')
            status = nf90_put_att(ncid, varid_layer, 'units', 'm')
            status = nf90_put_att(ncid, varid_layer, 'positive', 'down')
            status = nf90_put_att(ncid, varid_layer, 'axis', 'Z')
            status = nf90_put_att(ncid, varid_layer, 'cartesian_axis', 'Z')
            status = nf90_put_att(ncid, varid_layer, '_FillValue', -9999.0_dp)
        
        ! lath :
            ! Define the variable
            status = nf90_def_var(ncid, 'lath', NF90_doUBLE, dimids(2), varid_lath)    
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_lath, 'long_name', 'Latitude')
            status = nf90_put_att(ncid, varid_lath, 'Standard_name', 'latitude')
            status = nf90_put_att(ncid, varid_lath, 'units', 'degrees_north')
            status = nf90_put_att(ncid, varid_lath, 'axis', "Y")
            status = nf90_put_att(ncid, varid_lath, '_FillValue', -9999.0_dp)     
        
        ! lonh :
            ! Define the variable
            status = nf90_def_var(ncid, 'lonh', NF90_doUBLE, dimids(1), varid_longh)
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_longh, 'long_name', 'Longitude')
            status = nf90_put_att(ncid, varid_longh, 'Standard_name', 'longitude')
            status = nf90_put_att(ncid, varid_longh, 'units', 'degrees_east')
            status = nf90_put_att(ncid, varid_longh, 'axis', "X")
            status = nf90_put_att(ncid, varid_longh, '_FillValue', -9999.0_dp) 

        ! End the definitions mode: enter data mode
        status = nf90_enddef(ncid)

        ! Define valuse for each dimension : -----------------------------------------------------------
        status = nf90_put_var(ncid, varid_Time , 1)
        status = nf90_put_var(ncid, varid_layer, FEISTY%zt)
        status = nf90_put_var(ncid, varid_lath , FEISTY%lat(1, [2, 4, 6, 8]))
        status = nf90_put_var(ncid, varid_longh, FEISTY%lon([2,4,6,8], 1))
    end subroutine init_tracer_nc

    subroutine end_tracer_nc(ncid)
        integer, intent(in) :: ncid
        integer :: status

        ! Close the file
        status = nf90_close(ncid)
        if (status /= NF90_NOERR) then
            print *, "Error clossing ncdf in end_tracer_nc"
            print *, trim(nf90_strerror(status))
            STOP
        end if
    end subroutine end_tracer_nc

    subroutine add_tracer_nc(ncid, dimids, varname, long_name, var)
        character(LEN=*), intent(in) :: varname
        character(LEN=33), intent(in) ::  long_name
        integer, intent(in) :: dimids(4)
        integer, intent(in) :: ncid
        real(dp), dimension(FEISTY%Ntime,  FEISTY%Nlath, FEISTY%Nlongh), intent(in) :: var
        real(dp), dimension(FEISTY%Nlongh, FEISTY%Nlath, FEISTY%Ntime) ::  var_reshaped
        real(dp), dimension(FEISTY%Nlongh, FEISTY%Nlath, FEISTY%Nlayer, FEISTY%Ntime) ::  var_4D
        integer :: varid, status
        integer :: j, k, l
        
        ! Reshaping variable before saving for COBALT ouput:
        var_reshaped = RESHAPE(var, SHAPE(var_reshaped), ORDER = (/3, 2, 1/))

        ! Put opened netcdf into definition mode: 
        status = nf90_redef(ncid)

        ! Initialize var_4D with zeros
        var_4D = 0.0_dp
        ! Assign var_reshaped to the first layer of var_4D
        do l = 1, FEISTY%Ntime
            do k = 1, FEISTY%Nlath
                do j = 1, FEISTY%Nlongh
                    var_4D(j, k, 1, l) = var_reshaped(j, k, l)
                end do
            end do
        end do

        ! Save a 4D variables 
        status = nf90_def_var(ncid, varname, NF90_doUBLE, dimids([1, 2, 3, 4]), varid)
        if (status /= NF90_NOERR) then
            print *, "Error Def FEISTY: ", trim(varname)
            print *, trim(nf90_strerror(status))
            STOP
        end if
        
        ! Add a attributes: 
        status = nf90_put_att(ncid, varid, "long_name", trim(long_name))
        status = nf90_put_att(ncid, varid, 'units', 'gWW m-2')
        status = nf90_put_att(ncid, varid, 'checksum', "               0")
        status = nf90_put_att(ncid, varid, '_FillValue', -9999.0_dp)

        ! End the definitions mode: enter data mode
        status = nf90_enddef(ncid)

        ! Write the variable data
        status = nf90_put_var(ncid, varid, var_reshaped(1:FEISTY%Nlongh, 1:FEISTY%Nlath, FEISTY%Ntime))
        if (status /= NF90_NOERR) then
            print *, "Error in nf90_put_var: " , trim(varname), " in add_tracer_nc "
            print *, trim(nf90_strerror(status))
            STOP
        end if 
    end subroutine add_tracer_nc

    subroutine FEISTY_Save_diag()
        character(LEN=280) :: filename, String_Spinup
        integer(4) :: ncid, dimids(4), i
    
        if (Spinup_logical) then
            String_Spinup = "_Spinup_"
        else
            String_Spinup = "_"
        end if
    
        do i = 1, nFishGroup
            filename = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // "/" // trim(exp) // &
                       "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_" // &
                       trim(tracers_name(i)) // "_diag" // trim(String_Spinup) // "Time_Serie.nc"
    
            call init_Diag_nc(filename, ncid, dimids)
    
            call add_Diag_nc(ncid, dimids, "f", trim(tracers_name(i))    // " Feeding level", diags%fish(i)%f)
            call add_Diag_nc(ncid, dimids, "cmax", trim(tracers_name(i)) // " Maximum consumption rate", diags%fish(i)%cmax)
            call add_Diag_nc(ncid, dimids, "cons", trim(tracers_name(i)) // " Consumption", diags%fish(i)%cons)
            call add_Diag_nc(ncid, dimids, "met", trim(tracers_name(i))  // " Metabolic loss", diags%fish(i)%met)
            call add_Diag_nc(ncid, dimids, "mu_p", trim(tracers_name(i)) // " Predation Mortality", diags%fish(i)%mu_p)
            call add_Diag_nc(ncid, dimids, "mu_f", trim(tracers_name(i)) // " Fishing Mortality", diags%fish(i)%mu_f)
            call add_Diag_nc(ncid, dimids, "mu_a", trim(tracers_name(i)) // " Background Mortality", diags%fish(i)%mu_a)
            call add_Diag_nc(ncid, dimids, "mu", trim(tracers_name(i))   // " Mortality", diags%fish(i)%mu)
            call add_Diag_nc(ncid, dimids, "E_A", trim(tracers_name(i))  // " Energy Available", diags%fish(i)%E_A)
            call add_Diag_nc(ncid, dimids, "Fout", trim(tracers_name(i)) // " Flux out size class", diags%fish(i)%Fout)
            call add_Diag_nc(ncid, dimids, "Repro", trim(tracers_name(i))// " Reproductive output", diags%fish(i)%Repro)

            ! feeding levels:
            call add_Diag_nc(ncid, dimids, "f_Zm", trim(tracers_name(i)) // " Feeding level Medium Zoo", diags%fish(i)%f_Zm)
            call add_Diag_nc(ncid, dimids, "f_Zl", trim(tracers_name(i)) // " Feeding level Large Zoo", diags%fish(i)%f_Zl)
            call add_Diag_nc(ncid, dimids, "f_Sf", trim(tracers_name(i)) // " Feeding level Small forages", diags%fish(i)%f_Sf)
            call add_Diag_nc(ncid, dimids, "f_Sp", trim(tracers_name(i)) // " Feeding level Small pelagics", diags%fish(i)%f_Sp)
            call add_Diag_nc(ncid, dimids, "f_Sd", trim(tracers_name(i)) // " Feeding level Dmall Demersals", diags%fish(i)%f_Sd)
            call add_Diag_nc(ncid, dimids, "f_Mf", trim(tracers_name(i)) // " Feeding level Medium forages", diags%fish(i)%f_Mf)
            call add_Diag_nc(ncid, dimids, "f_Mp", trim(tracers_name(i)) // " Feeding level Medium pelagics", diags%fish(i)%f_Mp)
            call add_Diag_nc(ncid, dimids, "f_Md", trim(tracers_name(i)) // " Feeding level Medium Demersals", diags%fish(i)%f_Md)
            call add_Diag_nc(ncid, dimids, "f_Lp", trim(tracers_name(i)) // " Feeding level Large pelagics", diags%fish(i)%f_Lp)
            call add_Diag_nc(ncid, dimids, "f_Ld", trim(tracers_name(i)) // " Feeding level Large Demersals", diags%fish(i)%f_Ld)
            call add_Diag_nc(ncid, dimids, "f_BE", trim(tracers_name(i)) // " Feeding level Benthic resource", diags%fish(i)%f_BE)
            
            call end_Diag_nc(ncid)
            print *, trim(filename), " -- written"
        end do
    end subroutine FEISTY_Save_diag

    subroutine init_Diag_nc(filename, ncid, dimids)
        character(LEN = 280), intent(in) :: filename 
        integer, intent(inout) :: ncid, dimids(4)
        integer :: status
        integer :: Interface = 76, latq = 5, lonq = 5
        integer :: varid_time, varid_layer, varid_lath, varid_longh
        integer :: i
        real(dp), dimension(FEISTY%Ntime)  :: time_dim_val
        real(dp), dimension(FEISTY%Nlayer) :: layer_dim_val
        real(dp), dimension(FEISTY%Nlath)  :: lath_dim_val
        real(dp), dimension(FEISTY%Nlongh) :: longh_dim_val
        real(dp), dimension(8)      :: lath_temp_val, lonh_temp_val


        ! Create the NetCDF file
        status = nf90_create(filename, NF90_CLOBBER, ncid)
        if (status /= NF90_NOERR) then
            print *, "Error opening " , trim(filename), " in init_Diag_nc"
            print *, trim(nf90_strerror(status))
            STOP
        end if

        ! Define the dimensions : -----------------------------------------------------------
        status = nf90_def_dim(ncid, 'Time' , NF90_UNLIMITED,  dimids(4))
        if (status /= NF90_NOERR) then
            print *, trim(nf90_strerror(status))
            STOP
        end if
        status = nf90_def_dim(ncid, 'Layer', FEISTY%Nlayer, dimids(3))
        status = nf90_def_dim(ncid, 'lath' , FEISTY%Nlath , dimids(2))
        status = nf90_def_dim(ncid, 'lonh' , FEISTY%Nlongh, dimids(1))

        status = nf90_redef(ncid) ! Put opened netcdf into definition mode: 

        ! Define variables for each dimension: --------------------------------------------------------------
        ! Time: 
            ! Define the variable
            status = nf90_def_var(ncid, 'Time', NF90_doUBLE, dimids(4), varid_time)
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_time, 'long_name', 'Time')
            status = nf90_put_att(ncid, varid_time, 'Standard_name', 'time')
            status = nf90_put_att(ncid, varid_time, 'units', 'days')
            status = nf90_put_att(ncid, varid_time, 'calendar', 'proleptic_gregorian')
            status = nf90_put_att(ncid, varid_time, 'axis', "T")
            status = nf90_put_att(ncid, varid_time, '_FillValue', -9999.0_dp)

        ! Layer:
            ! Define the variable
            status = nf90_def_var(ncid, 'Layer', NF90_doUBLE, dimids(3), varid_layer)
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_layer, 'long_name', 'Layer')
            status = nf90_put_att(ncid, varid_layer, 'units', 'gWW m-2')
            status = nf90_put_att(ncid, varid_layer, 'positive', 'up')
            status = nf90_put_att(ncid, varid_layer, 'axis', 'Z')
            status = nf90_put_att(ncid, varid_layer, 'cartesian_axis', 'Z')
            status = nf90_put_att(ncid, varid_layer, '_FillValue', -9999.0_dp)
        
        ! lath :
            ! Define the variable
            status = nf90_def_var(ncid, 'lath', NF90_doUBLE, dimids(2), varid_lath)    
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_lath, 'long_name', 'Latitude')
            status = nf90_put_att(ncid, varid_lath, 'Standard_name', 'latitude')
            status = nf90_put_att(ncid, varid_lath, 'units', 'degrees_north')
            status = nf90_put_att(ncid, varid_lath, 'axis', "Y")
            status = nf90_put_att(ncid, varid_lath, '_FillValue', -9999.0_dp)     
        
        ! lonh :
            ! Define the variable
            status = nf90_def_var(ncid, 'lonh', NF90_doUBLE, dimids(1), varid_longh)
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_longh, 'long_name', 'Longitude')
            status = nf90_put_att(ncid, varid_longh, 'Standard_name', 'longitude')
            status = nf90_put_att(ncid, varid_longh, 'units', 'degrees_east')
            status = nf90_put_att(ncid, varid_longh, 'axis', "X")
            status = nf90_put_att(ncid, varid_longh, '_FillValue', -9999.0_dp) 

        status = nf90_enddef(ncid)  ! End the definitions mode: enter data mode


        ! Define valuse for each dimension : -----------------------------------------------------------
        ! get values from COBALT hgrid files       
        Time_dim_val = (/(i, i=1, FEISTY%Ntime, 1)/)
        call readgrid1D(dir_FEISTY_IC_YC, 'Layer',layer_dim_val) ! Use layer from this file (I cannot get the actual layer depth from the grid files generated for each location)
        ! Forcing long and lat from ocean_hgrid.nc (new method): 
        call readgrid1D(dir_loc_grid, 'y', lath_dim_val)
        call readgrid1D(dir_loc_grid, 'x', longh_dim_val)

        status = nf90_put_var(ncid, varid_Time , Time_dim_val)
        status = nf90_put_var(ncid, varid_layer, layer_dim_val)
        status = nf90_put_var(ncid, varid_lath,  lath_dim_val)
        status = nf90_put_var(ncid, varid_longh, longh_dim_val)
    end subroutine init_Diag_nc

    subroutine end_Diag_nc(ncid)
        integer, intent(in) :: ncid
        integer :: status

        ! Close the file
        status = nf90_close(ncid)
        if (status /= NF90_NOERR) then
            print *, "Error clossing ncdf in end_tracer_nc"
            print *, trim(nf90_strerror(status))
            STOP
        end if
    end subroutine end_Diag_nc

    subroutine add_Diag_nc(ncid, dimids, varname, long_name, var)
        integer, intent(in) :: dimids(4)
        integer, intent(in) :: ncid
        character(LEN=*), intent(in) :: varname
        character(LEN=*), intent(in) :: long_name
        real(dp), dimension(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh), intent(in) :: var
        real(dp), dimension(FEISTY%Nlongh, FEISTY%Nlath, FEISTY%Ntime) ::  var_reshaped
        integer :: varid
        integer :: status

        ! Reshaping variable before saving for COBALT ouput:
        var_reshaped = RESHAPE(var, SHAPE(var_reshaped), ORDER = (/3, 2, 1/))

        ! Put opened netcdf into definition mode: 
        status = nf90_redef(ncid)

        ! Define the variable
        status = nf90_def_var(ncid, varname, NF90_doUBLE, dimids([1,2,4]), varid)
        if (status /= NF90_NOERR) then
            print *, "Error Def FEISTY: ", trim(varname)
            print *, trim(nf90_strerror(status))
            STOP
        end if
        
        ! Add a attributes: 
        status = nf90_put_att(ncid, varid, "long_name", trim(long_name))
        status = nf90_put_att(ncid, varid, 'units', 'gWW m-2')
        status = nf90_put_att(ncid, varid, 'checksum', "               0")
        status = nf90_put_att(ncid, varid, '_FillValue', -9999.0_dp)

        ! End the definitions mode: enter data mode
        status = nf90_enddef(ncid)

        ! Write the variable data
        status = nf90_put_var(ncid, varid, var_reshaped(1:FEISTY%Nlongh, 1:FEISTY%Nlath, 1:FEISTY%Ntime)) !, &
                            !   start = (/1,      1,     1    ,  (Ntime-1) /), &
                            !   count = (/Nlongh, Nlath, Nlayer, 1         /))
        if (status /= NF90_NOERR) then
            print *, "Error in nf90_put_var: " , trim(varname), " in add_tracer_nc "
            print *, trim(nf90_strerror(status))
            STOP
        end if        
    end subroutine add_Diag_nc

 
end module GetNetCDFinf