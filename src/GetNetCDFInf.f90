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
    ! Spinup: logical, if true, the model will run for 100 years
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
    subroutine Init_FEISTY(Spinup, FEISTY, diags, IC_tracers_Bio, tracers, &
                            DataTemp, Datadet, Datadzm, DataZM, Datadzl, DataZL)                 
        logical, intent(in) :: Spinup
        type(FEISTY_type)       , intent(inout) :: FEISTY
        type(FEISTY_diag)       , intent(inout) :: diags
        type(FEISTY_tracers)    , intent(inout), dimension(nDeriv)  :: tracers
        type(Initial_conditions), intent(inout), dimension(nDeriv)  :: IC_tracers_Bio
        real(dp), dimension(:, :, :, :), allocatable, intent(inout) ::  DataTemp, &
                                                                        Datadzm, DataZM, &
                                                                        Datadzl, DataZL, &
                                                                        Datadet
        integer                             :: Ntime, Nlayer, Nlath, Nlongh                                                                        
        real(dp), dimension(9, 9)           :: Datalat, Datalon
        real(dp), dimension(4, 4)           :: Datamax_depth
        real(dp), dimension(:), allocatable :: Datazt ! pseudo layer depth
        integer :: i, i_100m

        CALL Get_dim(dir_Temp, Ntime, Nlayer, Nlath, Nlongh)  ! Get the dimension of the data used to force the model
        allocate(Datazt(Nlayer))
        CALL load_forcing_data(Ntime, Nlayer, Nlath, Nlongh, DataTemp, Datadet, Datadzm, DataZM, Datadzl, DataZL, &
                                Datazt, Datalat, Datalon, Datamax_depth) ! Load the data used to force the model
        Call load_IC_fish(Spinup, Nlath, Nlongh, IC_tracers_Bio) ! Load the initial condition of the model
        ! 
        if (Spinup) then 
            Ntime = Ntime * Year_2_Spinup
        end if

        ! Save the dimension of the forcing files in the FEISTY structure
        FEISTY%Ntime  = Ntime
        FEISTY%Nlayer = Nlayer
        FEISTY%Nlath  = Nlath
        FEISTY%Nlongh  = Nlongh
        ! FEISTY%time   = real(Ntime)
        ! FEISTY%layer  = real(Nlayer)
        ! FEISTY%lath   = real(Nlath)
        ! FEISTY%longh  = real(Nlongh) 
        FEISTY%zt  = Datazt  ! pseudo layer depth 
        FEISTY%lat = Datalat ! latitude 
        FEISTY%lon = Datalon ! longitude
        FEISTY%max_depth = Datamax_depth(1,1) ! max depth

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
        CALL allocate_tracers(tracers, Ntime, Nlath, Nlongh)
        CALL allocate_diags(diags, Ntime, Nlath, Nlongh)
        
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
    subroutine Get_dim(dir, Ntime, Nlayer, Nlath, Nlongh)
        character(LEN=280), intent(in) :: dir
        integer, intent(inout) :: Ntime, Nlayer, Nlath, Nlongh
        integer :: ncid
        integer, dimension(4) :: dim
        character(LEN=250) :: xname, yname, zname, hname
        integer :: ierr
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
    end subroutine Get_dim

    !:====================================================================== 
    ! Load all the imput values to force the model
    !:======================================================================  
    subroutine load_forcing_data(Ntime, Nlayer, Nlath, Nlongh, DataTemp, &
                                 Datadet, Datadzm, DataZM, Datadzl, DataZL, &
                                 Datazt, Datalat, Datalon, Datamax_depth)
        ! Declare variables
        real(dp), dimension(:, :, :, :), allocatable, intent(inout) ::  DataTemp, &
                                                                        Datadzm, DataZM, &
                                                                        Datadzl, DataZL, &
                                                                        Datadet
        integer, intent(in)                                         :: Ntime, Nlayer, Nlath, Nlongh
        real(dp), dimension(9, 9), intent(inout)                    :: Datalat, Datalon
        real(dp), dimension(4, 4), intent(inout)                    :: Datamax_depth
        real(dp), dimension(Nlayer), intent(inout)                  :: Datazt ! pseudo layer depth

        ! Get the input grid data to force the model: 
        ! Get physiological data:
        CALL readgrid4D(dir_Temp, var_Temp, Ntime, Nlayer, Nlath, Nlongh, DataTemp)
        CALL readgrid4D(dir_zm, var_zm, Ntime, Nlayer, Nlath, Nlongh, DataZM)
        CALL readgrid4D(dir_dzm, var_dzm, Ntime, Nlayer, Nlath, Nlongh, Datadzm)
        CALL readgrid4D(dir_zl, var_zl, Ntime, Nlayer, Nlath, Nlongh, DataZL)
        CALL readgrid4D(dir_dzl, var_dzl, Ntime, Nlayer, Nlath, Nlongh, Datadzl)
        CALL readgrid4D(dir_det, var_det, Ntime, Nlayer, Nlath, Nlongh, Datadet)
        
        ! Get data about the location 
        CALL readgrid1D(dir_zt, var_zt, Nlayer, Datazt)  ! pseudo layer depth 
        CALL readgrid2D(dir_lat, var_lat, int(9), int(9), Datalat) ! latitude 
        CALL readgrid2D(dir_lon, var_lon, int(9), int(9),  Datalon) ! longitude
        CALL readgrid2D(dir_max_depth, var_max_depth, int(9), int(9),  Datamax_depth) ! max depth   

        ! Convert depth grid into actual depth:
        ! var_zt is constant for every location and goes from 1 to  6212.405 m depth,
        ! we use maxdepth of the location 'var_max_depth' to rescale the depth. 
        Datazt = Datazt * Datamax_depth(1,1) / 6212.405

    end subroutine load_forcing_data

    !:====================================================================== 
    ! Load all the Spinup Initial condition to force the FEISTY
    !:======================================================================  
    subroutine load_IC_fish(Spinup, Nlath, Nlongh, IC_tracers_Bio)
        logical, intent(in) :: Spinup
        integer, intent(in) :: Nlath, Nlongh
        type(Initial_conditions), intent(inout), dimension(nDeriv) :: IC_tracers_Bio

        if (Spinup .eqv. .false.) then 
            call allocate_IC_tracers_Bio(IC_tracers_Bio, Nlath, Nlongh)
            CALL readgrid2D(dir_IniSf, 'Sf', Nlath, Nlongh, IC_tracers_Bio(1)%IniBio)
            CALL readgrid2D(dir_IniSp, 'Sp', Nlath, Nlongh, IC_tracers_Bio(2)%IniBio)
            CALL readgrid2D(dir_IniSd, 'Sd', Nlath, Nlongh, IC_tracers_Bio(3)%IniBio)
            CALL readgrid2D(dir_IniMf, 'Mf', Nlath, Nlongh, IC_tracers_Bio(4)%IniBio)
            CALL readgrid2D(dir_IniMp, 'Mp', Nlath, Nlongh, IC_tracers_Bio(5)%IniBio)
            CALL readgrid2D(dir_IniMd, 'Md', Nlath, Nlongh, IC_tracers_Bio(6)%IniBio)
            CALL readgrid2D(dir_IniLp, 'Lp', Nlath, Nlongh, IC_tracers_Bio(7)%IniBio)
            CALL readgrid2D(dir_IniLd, 'Ld', Nlath, Nlongh, IC_tracers_Bio(8)%IniBio)
            CALL readgrid2D(dir_IniBE, 'BE', Nlath, Nlongh, IC_tracers_Bio(9)%IniBio)
        end if
    end subroutine load_IC_fish

    !:====================================================================== 
    ! Write the output in netCDF files
    !:======================================================================     
    subroutine write_output_netcdf(Spinup, tracers, diags, Ntime, Nlayer, Nlath, Nlongh, lat, lon, zt)
        type(FEISTY_tracers), intent(inout), dimension(nDeriv) :: tracers
        type(FEISTY_diag)   :: diags
        logical, intent(in) :: Spinup
        integer, intent(in) :: Ntime, Nlayer, Nlath, Nlongh
        real(dp), dimension(9,9):: lat, lon
        real(dp), dimension(75) :: zt
        integer :: i
    
        if (Spinup) then
            do i = 1, nDeriv
                call write_nc_file3D(Dir_IC(i), tracers_name(i), tracers(i)%Bio(Ntime, 1:Nlath, 1:Nlongh), &
                                     Nlayer, Nlath, Nlongh)
            end do
            
            if (Spinup_Time_Serie) then 
                do i = 1, nDeriv
                    call write_nc_file4D("../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
                        "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) //&
                        "_" // trim(tracers_name(i)) // "_bio_Spinup_Time_Serie.nc",&
                        trim(tracers_name(i)), tracers(i)%Bio, Ntime, Nlayer, Nlath, Nlongh)
                end do 
            end if 

            if(Initial_Condition_generic_FEISTY) then 
                call FEISTY_Save_IC(Spinup, tracers, Ntime, Nlayer, Nlath, Nlongh, lat, lon, zt) 
            end if 

        else
            ! Write each variable to a separate NetCDF file : ---------------------------
            do i = 1, nDeriv
                call write_nc_file4D("../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
                        "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) //&
                        "_" // trim(tracers_name(i)) // "_bio.nc", & 
                        trim(tracers_name(i)), tracers(i)%Bio, Ntime, Nlayer, Nlath, Nlongh)
            end do 
            !! Reformat !! 
            call write_nc_file4D("../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
                        "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) //&
                        "_dZm.nc", "dZm", diags%mesozoo(1)%Zcon_VS_dZ, & 
                        Ntime, Nlayer, Nlath, Nlongh)
            call write_nc_file4D("../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
                        "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) //&
                        "_dZl.nc", "dZl", diags%mesozoo(2)%Zcon_VS_dZ, & 
                        Ntime, Nlayer, Nlath, Nlongh)

            if(save_diagnostics) then 
                call FEISTY_Save_diag(Spinup, diags, Ntime, Nlayer, Nlath, Nlongh, lat, lon, zt)
            end if   
        end if 
    end subroutine write_output_netcdf 

    subroutine write_nc_file4D(filename, varname, var, Ntime, Nlayer, Nlath, Nlongh)
        character(*), intent(in) :: filename, varname
        integer, intent(in) :: Ntime, Nlayer, Nlath, Nlongh
        real(dp), dimension(Ntime, Nlath, Nlongh), intent(in) :: var
        integer :: ncid, dimids(4), varid
        integer :: status

        ! Create the NetCDF file
        status = nf90_create(filename, NF90_CLOBBER, ncid)
        
        ! Define the dimensions
        status = nf90_def_dim(ncid, 'Time'  , Ntime  , dimids(1))
        status = nf90_def_dim(ncid, 'Layer' , Nlayer , dimids(2))
        status = nf90_def_dim(ncid, 'Lath'  , Nlath  , dimids(3))
        status = nf90_def_dim(ncid, 'Longh' , Nlongh , dimids(4))

        ! Define the variable
        status = nf90_def_var(ncid, varname, NF90_REAL, dimids([1,3,4]), varid)

        ! End the definitions mode
        status = nf90_enddef(ncid)
        
        ! Write the variable data
        status = nf90_put_var(ncid, varid, var)

        ! add a unit attribute 
        status = nf90_put_att(ncid, varid, 'units', 'gWW m-2')
        
        ! Close the file
        status = nf90_close(ncid)

        print *, filename, " written"
    end subroutine write_nc_file4D

    subroutine write_nc_file3D(filename, varname, var, Nlayer, Nlath, Nlongh)
        character(*), intent(in) :: filename, varname
        integer, intent(in) :: Nlayer, Nlath, Nlongh
        real(dp), dimension(Nlath, Nlongh), intent(in) :: var
        integer :: ncid, dimids(3), varid
        integer :: status

        ! Create the NetCDF file
        status = nf90_create(filename, NF90_CLOBBER, ncid)
        
        ! Define the dimensions
        status = nf90_def_dim(ncid, 'Layer' , Nlayer , dimids(1))
        status = nf90_def_dim(ncid, 'Lath'  , Nlath  , dimids(2))
        status = nf90_def_dim(ncid, 'Longh' , Nlongh , dimids(3))

        ! Define the variable
        status = nf90_def_var(ncid, varname, NF90_REAL, dimids(2:3), varid)

        ! End the definitions mode
        status = nf90_enddef(ncid)
        
        ! Write the variable data
        status = nf90_put_var(ncid, varid, var)

        ! add a unit attribute 
        status = nf90_put_att(ncid, varid, 'units', 'gWW m-2')
        
        ! Close the file
        status = nf90_close(ncid)
    end subroutine write_nc_file3D


    !:====================================================================== 
    ! Get the input values for the given lat long and time 
    ! integrate all over depth and store them in the FEISTY structure
    !:======================================================================  
    subroutine Get_Environental_data(FEISTY, DataTemp, Datadet, &
                                     Datadzm, DataZM, Datadzl, DataZL)
        type(FEISTY_type), intent(inout) :: FEISTY
        real(dp), dimension(FEISTY%Nlayer), intent(inout) ::    DataTemp, &
                                                                Datadzm, DataZM, &
                                                                Datadzl, DataZL, &
                                                                Datadet
        
        FEISTY%Tp = sum(DataTemp(FEISTY%idx_100m))/size(FEISTY%idx_100m)
        FEISTY%Tb = DataTemp(FEISTY%Nlayer)
        FEISTY%mesozoo(1)%B  = sum(DataZM(FEISTY%idx_100m)  * FEISTY%layer_thickness(FEISTY%idx_100m)) * convers_zm
        FEISTY%mesozoo(2)%B  = sum(DataZL(FEISTY%idx_100m)  * FEISTY%layer_thickness(FEISTY%idx_100m)) * convers_zm
        FEISTY%mesozoo(1)%dz = sum(Datadzm(FEISTY%idx_100m)) * convers_dZm ! do not multiply by layer thickness as the output values is a "layer integral" 
        FEISTY%mesozoo(2)%dz = sum(Datadzl(FEISTY%idx_100m)) * convers_dZm
        FEISTY%det  = Datadet(FEISTY%Nlayer) * convers_det        
        
        ! print *,  "FEISTY%Tp:", FEISTY%Tp
        ! print *,  "FEISTY%Tb:", FEISTY%Tb
        ! print *,  "FEISTY%mesozoo(1)%dz:", FEISTY%mesozoo(1)%dz
        ! print *,  "FEISTY%mesozoo(1)%B:", FEISTY%mesozoo(1)%B
        ! print *,  "FEISTY%mesozoo(2)%dz:", FEISTY%mesozoo(2)%dz
        ! print *,  "FEISTY%mesozoo(2)%B:", FEISTY%mesozoo(2)%B
        ! print *,  "FEISTY%det:", FEISTY%det

    end subroutine Get_Environental_data


    subroutine readgrid4D(dir, varname, Ntime, Nlayer, Nlath, Nlongh, values)
        character(LEN=280), intent(in) :: dir, varname
        integer, intent(in) :: Ntime, Nlayer, Nlath, Nlongh
        real(dp), dimension(:, :, :, :), allocatable, intent(inout) :: values
        integer :: ierr, vartype, ndims, nAtts, ncid, varid
        integer, dimension(4) :: start, count

        allocate(values(Nlongh, Nlath, Nlayer, Ntime))

        ! Open NetCDF: --------------------------------------------
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, nf90_strerror(ierr)
            print *, "Error opening file: ", trim(dir)
            stop
        end if
        
        ! Get variable id: 
        ierr = nf90_inq_varid(ncid, varname, varid)
        if (ierr /= NF90_NOERR) then
            print *, "Error nf90_inquire_variable: ", nf90_strerror(ierr)
            stop
        end if

        ! Get values of the variable 
        ierr = nf90_get_var(ncid, varid, values) ! , start = start, count = count
        if (ierr /= NF90_NOERR) then
            print *, "Error nf90_get_var: ", nf90_strerror(ierr)
            stop
        end if
        
        ! Close the netCDF files : ----------------------------------------------------------------
        ierr = nf90_close(ncid)

        print*, trim(varname), " loaded"
        print*, "dir : ", trim(dir)
    end subroutine readgrid4D

    subroutine readgrid3D(dir, varname, Nlayer, Nlath, Nlongh, values)
        character(LEN=*), intent(in) :: dir, varname
        integer, intent(in) :: Nlayer, Nlath, Nlongh
        real(dp), dimension(:, :, :), allocatable, intent(inout) :: values
        integer :: ierr, vartype, nAtts, ncid, varid
        integer, dimension(3) :: ndims

        allocate(values(Nlayer, Nlath, Nlongh))
        
        ! Open NetCDF: --------------------------------------------
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, nf90_strerror(ierr)
            print *, "Error opening file: ", trim(dir)
            stop
        end if
        
        ! Get variable id: 
        ierr = nf90_inq_varid(ncid, varname, varid)
        if (ierr /= NF90_NOERR) then
            print *, "Error nf90_inquire_variable: ", nf90_strerror(ierr)
            stop
        end if

        ! Get values of the variable 
        ierr = nf90_get_var(ncid, varid, values) ! , start = start, count = count
        if (ierr /= NF90_NOERR) then
            print *, "Error nf90_get_var: ", nf90_strerror(ierr)
            stop
        end if

        print *, "Initial condition ", trim(varname), " loaded"
        
        ! Close the netCDF files : ----------------------------------------------------------------
        ierr = nf90_close(ncid)
    end subroutine readgrid3D

    subroutine readgrid2D(dir, varname, Dim1, Dim2, values)
        character(LEN=*), intent(in) :: dir, varname
        integer, intent(in) :: Dim1, Dim2
        real(dp), dimension(:, :), intent(inout) :: values
        integer :: ierr, vartype, nAtts, ncid, varid
        integer, dimension(3) :: ndims

        ! allocate(values(9, 9))
        
        ! Open NetCDF: --------------------------------------------
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, nf90_strerror(ierr)
            print *, "Error opening file: ", trim(dir)
            stop
        end if
        
        ! Get variable id: 
        ierr = nf90_inq_varid(ncid, varname, varid)
        if (ierr /= NF90_NOERR) then
            print *, "Error in ", trim(varname), " nf90_inquire_variable: ", nf90_strerror(ierr)
            stop
        end if

        ! Get values of the variable 
        ierr = nf90_get_var(ncid, varid, values) ! , start = start, count = count
        if (ierr /= NF90_NOERR) then
            print *, "Error in ", trim(varname), " nf90_get_var: ", nf90_strerror(ierr)
            stop
        end if
        print *, "Initial condition ", trim(varname), " loaded"
        
        ! Close the netCDF files : ----------------------------------------------------------------
        ierr = nf90_close(ncid)
    end subroutine readgrid2D

    subroutine readgrid1D(dir, varname, Dim1, values)
        character(LEN=*), intent(in) :: dir, varname
        integer, intent(in) :: Dim1
        real(dp), dimension(Dim1), intent(inout) :: values
        integer :: ierr, vartype, nAtts, ncid, varid
        integer, dimension(3) :: ndims

        ! Open NetCDF: --------------------------------------------
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, nf90_strerror(ierr)
            print *, "Error opening file: ", trim(dir)
            stop
        end if
        
        ! Get variable id: 
        ierr = nf90_inq_varid(ncid, varname, varid)
        if (ierr /= NF90_NOERR) then
            print *, "Error in ", trim(varname), " nf90_inquire_variable: ", nf90_strerror(ierr)
            stop
        end if

        ! Get values of the variable 
        ierr = nf90_get_var(ncid, varid, values) ! , start = start, count = count
        if (ierr /= NF90_NOERR) then
            print *, "Error in ", trim(varname), " nf90_get_var: ", nf90_strerror(ierr)
            stop
        end if
        
        ! Close the netCDF files : ----------------------------------------------------------------
        ierr = nf90_close(ncid)
    end subroutine readgrid1D

    subroutine FEISTY_Save_IC(Spinup, tracers, Ntime, Nlayer, Nlath, Nlongh, lat, lon, zt)
        logical, intent(in) :: Spinup
        type(FEISTY_tracers), intent(inout), dimension(nDeriv) :: tracers
        integer, intent(in)                         :: Ntime, Nlayer, Nlath, Nlongh
        real(dp), dimension(9,9), intent(in)        :: lat, lon
        real(dp), dimension(75), intent(in)         :: zt
        real(dp), dimension(Ntime, Nlath, Nlongh)   :: hp_ingest_nmdz
        character(LEN=280) :: filename 
        integer(4) :: ncid, dimids(4)
        integer :: i,j,k,l
        

        filename = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // "/FEISTY_2D_2023_10_spinup_subset.nc"
        call init_tracer_nc(filename, ncid, Ntime, Nlayer, Nlath, Nlongh, dimids, lat, lon, zt)
        do i = 1, nDeriv
            call add_tracer_nc(ncid, dimids, trim(tracers_name(i)) // "_B", tracers_long_name(i), &
                                        tracers(i)%Bio, Ntime, Nlayer, Nlath, Nlongh)
        end do
        ! add hp_ingest_nmdz and hp_ingest_nmdz for COBALT initialisation:
        hp_ingest_nmdz(:,:,:) = 0.0_dp
        call add_tracer_nc(ncid, dimids, "hp_ingest_nmdz", "fish ingestion of medium zooplankton", &
                            hp_ingest_nmdz, Ntime, Nlayer, Nlath, Nlongh)
        call add_tracer_nc(ncid, dimids, "hp_ingest_nlgz", "fish ingestion of large zooplankton", &
                            hp_ingest_nmdz, Ntime, Nlayer, Nlath, Nlongh)
        call end_tracer_nc(ncid)
        print*, "COBALT IC saved :", filename
    end subroutine FEISTY_Save_IC


    subroutine init_tracer_nc(filename, ncid, Ntime, Nlayer, Nlath, Nlongh, dimids, lat, lon, zt)
        character(LEN = 280), intent(in)        :: filename 
        integer, intent(inout)                  :: ncid, dimids(4)
        integer, intent(in)                     :: Ntime, Nlayer, Nlath, Nlongh
        real(dp), dimension(9,9), intent(in)    :: lat, lon
        real(dp), dimension(75) , intent(in)    :: zt
        integer :: status
        integer :: varid_time, varid_layer, varid_lath, varid_longh
        integer :: i
        real(dp), dimension(Ntime) :: time_dim_val
        real(dp), dimension(Nlayer) :: layer_dim_val
        real(dp), dimension(Nlath)  :: lath_dim_val
        real(dp), dimension(Nlongh) :: longh_dim_val
        real(dp), dimension(8)  :: lath_temp_val, lonh_temp_val

        print*, "Creating NetCDF file for tracers: ", filename

        ! Create the NetCDF file
        status = nf90_create(filename, NF90_CLOBBER, ncid)
        if (status /= NF90_NOERR) then
            print *, "Error opening " , trim(filename), " in init_tracer_nc"
            print *, trim(nf90_strerror(status))
            STOP
        end if

        ! Define the dimensions
        status = nf90_def_dim(ncid, 'Time' , NF90_UNLIMITED,  dimids(4))
        if (status /= NF90_NOERR) then
            print *, trim(nf90_strerror(status))
            STOP
        end if
        status = nf90_def_dim(ncid, 'Layer', Nlayer, dimids(3))
        status = nf90_def_dim(ncid, 'lath' , Nlath , dimids(2))
        status = nf90_def_dim(ncid, 'lonh' , Nlongh, dimids(1))

        !! Define variables for each dimension: --------------------------------------------------------------
        ! Time: 
            ! Define the variable
            status = nf90_def_var(ncid, 'Time', NF90_DOUBLE, dimids(4), varid_time)
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_time, 'long_name', 'Time')
            status = nf90_put_att(ncid, varid_time, 'Standard_name', 'time')
            status = nf90_put_att(ncid, varid_time, 'units', 'days')
            status = nf90_put_att(ncid, varid_time, 'calendar', 'proleptic_gregorian')
            status = nf90_put_att(ncid, varid_time, 'axis', "T")
            status = nf90_put_att(ncid, varid_time, '_FillValue', -9999.0_dp)

        ! Layer:
            ! Define the variable
            status = nf90_def_var(ncid, 'Layer', NF90_DOUBLE, dimids(3), varid_layer)
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_layer, 'long_name', 'Layer')
            status = nf90_put_att(ncid, varid_layer, 'units', 'm')
            status = nf90_put_att(ncid, varid_layer, 'positive', 'down')
            status = nf90_put_att(ncid, varid_layer, 'axis', 'Z')
            status = nf90_put_att(ncid, varid_layer, 'cartesian_axis', 'Z')
            status = nf90_put_att(ncid, varid_layer, '_FillValue', -9999.0_dp)
        
        ! lath :
            ! Define the variable
            status = nf90_def_var(ncid, 'lath', NF90_DOUBLE, dimids(2), varid_lath)    
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_lath, 'long_name', 'Latitude')
            status = nf90_put_att(ncid, varid_lath, 'Standard_name', 'latitude')
            status = nf90_put_att(ncid, varid_lath, 'units', 'degrees_north')
            status = nf90_put_att(ncid, varid_lath, 'axis', "Y")
            status = nf90_put_att(ncid, varid_lath, '_FillValue', -9999.0_dp)     
        
        ! lonh :
            ! Define the variable
            status = nf90_def_var(ncid, 'lonh', NF90_DOUBLE, dimids(1), varid_longh)
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_longh, 'long_name', 'Longitude')
            status = nf90_put_att(ncid, varid_longh, 'Standard_name', 'longitude')
            status = nf90_put_att(ncid, varid_longh, 'units', 'degrees_east')
            status = nf90_put_att(ncid, varid_longh, 'axis', "X")
            status = nf90_put_att(ncid, varid_longh, '_FillValue', -9999.0_dp) 

        ! End the definitions mode: enter data mode
        status = nf90_enddef(ncid)

        ! Define valuse for each dimension : -----------------------------------------------------------
        ! Time in days:
        Time_dim_val = 1
        ! Layer pseudo-depth: 
        layer_dim_val = zt
        ! lat and long 
        ! lath_temp_val = lat(1, 1) + (lat(1:8, 1) - lat(2:9, 1))/2
        ! lonh_temp_val = lon(1, 1) + (lon(1, 1:8) - lon(1, 2:9))/2 
        lath_dim_val  = lat(1, [2, 4, 6, 8])
        longh_dim_val = lon([2,4,6,8], 1)
        ! print*, "dim lat", size(lat, 1), size(lat, 2)
        ! print*, "dim lon", size(lon, 1), size(lon, 2)
        ! print *, "lat", lat(1, [1,2])
        ! print *, "lon", lat(1, 1), lat(1, 2)
        ! print *, 'lath_dim_val', lath_dim_val
        ! print *,  'longh_dim_val', longh_dim_val

        status = nf90_put_var(ncid, varid_Time, 1)
        status = nf90_put_var(ncid, varid_layer, layer_dim_val)
        status = nf90_put_var(ncid, varid_lath,  lath_dim_val)
        status = nf90_put_var(ncid, varid_longh, longh_dim_val)

        ! print*, "layer_dim_val ", layer_dim_val
        ! print*, "lath_dim_val " , lath_dim_val
        ! print*, "longh_dim_val ", longh_dim_val

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

    subroutine add_tracer_nc(ncid, dimids, varname, long_name, var, Ntime, Nlayer, Nlath, Nlongh)
        character(LEN=*), intent(in) :: varname
        character(LEN=33), intent(in) ::  long_name
        integer, intent(in) :: dimids(4)
        integer, intent(in) :: ncid, Ntime, Nlayer, Nlath, Nlongh
        real(dp), dimension(Ntime, Nlath, Nlongh), intent(in) :: var
        real(dp), dimension(Nlongh, Nlath, Ntime) ::  var_reshaped
        real(dp), dimension(Nlongh, Nlath, Nlayer, Ntime) ::  var_4D
        integer :: varid, status
        integer :: j, k, l
        
        ! Reshaping variable before saving for COBALT ouput:
        var_reshaped = RESHAPE(var, SHAPE(var_reshaped), ORDER = (/3, 2, 1/))

        ! Put opened netcdf into definition mode: 
        status = nf90_redef(ncid)

        ! Initialize var_4D with zeros
        var_4D = 0.0_dp

        ! Assign var_reshaped to the first layer of var_4D
        do l = 1, Ntime
            do k = 1, Nlath
                do j = 1, Nlongh
                    var_4D(j, k, 1, l) = var_reshaped(j, k, l)
                end do
            end do
        end do


        ! ! Define the variable
        ! status = nf90_def_var(ncid, varname, NF90_DOUBLE, dimids([1, 2, 4]), varid)
        ! if (status /= NF90_NOERR) then
        !     print *, "Error Def FEISTY: ", trim(varname)
        !     print *, trim(nf90_strerror(status))
        !     STOP
        ! end if
        ! Save a 4D variables 
        status = nf90_def_var(ncid, varname, NF90_DOUBLE, dimids([1, 2, 3, 4]), varid)
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
        status = nf90_put_var(ncid, varid, var_reshaped(1:Nlongh, 1:Nlath, Ntime))
        if (status /= NF90_NOERR) then
            print *, "Error in nf90_put_var: " , trim(varname), " in add_tracer_nc "
            print *, trim(nf90_strerror(status))
            STOP
        end if 
    end subroutine add_tracer_nc

    subroutine FEISTY_Save_diag(Spinup, diags, Ntime, Nlayer, Nlath, Nlongh, lat, lon, zt)
        type(FEISTY_diag)                       :: diags
        logical, intent(in)                     :: Spinup
        integer, intent(in)                     :: Ntime, Nlayer, Nlath, Nlongh
        real(dp), dimension(9,9), intent(in)    :: lat, lon
        real(dp), dimension(75), intent(in)     :: zt
        character(LEN=280)  :: filename, String_Spinup 
        integer(4)          :: ncid, dimids(4), i, j

        if(Spinup) then 
            String_Spinup = "_Spinup_"
        else 
            String_Spinup = "_"
        end if 

        Do i = 1, nFishGroup
            filename =  "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
                        "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_" //  &
                        trim(tracers_name(i)) // "_diag" // trim(String_Spinup) // "Time_Serie.nc"

            call init_Diag_nc(Spinup, filename, ncid, Ntime, Nlayer, Nlath, Nlongh, dimids, lat, lon, zt)
            
            call add_Diag_nc(ncid, dimids, "f",    trim(tracers_name(i)) // " Feeding level"            , &
                                diags%fish(i)%f    , Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "cmax", trim(tracers_name(i)) // " Maximum consumption rate ", &
                                diags%fish(i)%cmax , Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "cons", trim(tracers_name(i)) // " Consumption"              , &
                                diags%fish(i)%cons , Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "met",  trim(tracers_name(i)) // " Metabolic loss"           , &
                                diags%fish(i)%met  , Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "mu_p", trim(tracers_name(i)) // " Predation Mortality"      , &
                                diags%fish(i)%mu_p , Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "mu_f", trim(tracers_name(i)) // " Fishing Mortality"        , &
                                diags%fish(i)%mu_f , Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "mu_a", trim(tracers_name(i)) // " Background Mortality"     , &
                                diags%fish(i)%mu_a , Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "mu",   trim(tracers_name(i)) // " Mortality "               , &
                                diags%fish(i)%mu   , Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "E_A",  trim(tracers_name(i)) // " Energy Available"         , &
                                diags%fish(i)%E_A  , Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "Fout", trim(tracers_name(i)) // " Flux out size class"      , &
                                diags%fish(i)%Fout , Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "Repro",trim(tracers_name(i)) // " Reproductive output"      , &
                                diags%fish(i)%Repro, Ntime, Nlayer, Nlath, Nlongh)

            call add_Diag_nc(ncid, dimids, "f_Zm", trim(tracers_name(i)) // " Feeding level Medium Zoo     ", &
                                diags%fish(i)%f_Zm, Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "f_Zl", trim(tracers_name(i)) // " Feeding level Large Zoo      ", &
                                diags%fish(i)%f_Zl, Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "f_Sf", trim(tracers_name(i)) // " Feeding level Small Forage   ", &
                                diags%fish(i)%f_Sf, Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "f_Sp", trim(tracers_name(i)) // " Feeding level Small Pelagic  ", &
                                diags%fish(i)%f_Sp, Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "f_Sd", trim(tracers_name(i)) // " Feeding level Small Demersal ", &
                                diags%fish(i)%f_Sd, Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "f_Mf", trim(tracers_name(i)) // " Feeding level Medium Forage  ", &
                                diags%fish(i)%f_Mf, Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "f_Mp", trim(tracers_name(i)) // " Feeding level Medium Pelagic ", &
                                diags%fish(i)%f_Mp, Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "f_Md", trim(tracers_name(i)) // " Feeding level Medium Demersal", &
                                diags%fish(i)%f_Md, Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "f_Lp", trim(tracers_name(i)) // " Feeding level Large Pelagic  ", &
                                diags%fish(i)%f_Lp, Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "f_Ld", trim(tracers_name(i)) // " Feeding level Large Demersal ", &
                                diags%fish(i)%f_Ld, Ntime, Nlayer, Nlath, Nlongh)
            call add_Diag_nc(ncid, dimids, "f_BE", trim(tracers_name(i)) // " Feeding level Benthos        ", &
                                diags%fish(i)%f_BE, Ntime, Nlayer, Nlath, Nlongh)

            call end_Diag_nc(ncid)

            print *, trim(filename), " -- written" 
        end Do 

    end subroutine FEISTY_Save_diag

    subroutine init_Diag_nc(Spinup, filename, ncid, Ntime, Nlayer, Nlath, Nlongh, dimids, lat, lon, zt)
        logical, intent(in) :: Spinup
        character(LEN = 280), intent(in) :: filename 
        integer, intent(inout) :: ncid, dimids(4)
        integer, intent(in) :: Ntime, Nlayer, Nlath, Nlongh
        real(dp), dimension(9,9), intent(in)    :: lat, lon
        real(dp), dimension(75), intent(in)     :: zt
        integer :: status
        integer :: Interface = 76, latq = 5, lonq = 5
        integer :: varid_time, varid_layer, varid_lath, varid_longh
        integer :: i
        real(dp), dimension(Ntime)  :: time_dim_val
        real(dp), dimension(Nlayer) :: layer_dim_val
        real(dp), dimension(Nlath)  :: lath_dim_val
        real(dp), dimension(Nlongh) :: longh_dim_val
        real(dp), dimension(8)  :: lath_temp_val, lonh_temp_val


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
        status = nf90_def_dim(ncid, 'Layer', Nlayer, dimids(3))
        status = nf90_def_dim(ncid, 'lath' , Nlath , dimids(2))
        status = nf90_def_dim(ncid, 'lonh' , Nlongh, dimids(1))
        !status = nf90_def_dim(ncid, 'lonq' , lonq  , dimids(3))
        !status = nf90_def_dim(ncid, 'latq' , latq  , dimids(2))
        !status = nf90_def_dim(ncid, 'Interface' , Interface, dimids(1))

        status = nf90_redef(ncid) ! Put opened netcdf into definition mode: 

        ! Define variables for each dimension: --------------------------------------------------------------
        ! Time: 
            ! Define the variable
            status = nf90_def_var(ncid, 'Time', NF90_DOUBLE, dimids(4), varid_time)
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_time, 'long_name', 'Time')
            status = nf90_put_att(ncid, varid_time, 'Standard_name', 'time')
            status = nf90_put_att(ncid, varid_time, 'units', 'days')
            status = nf90_put_att(ncid, varid_time, 'calendar', 'proleptic_gregorian')
            status = nf90_put_att(ncid, varid_time, 'axis', "T")
            status = nf90_put_att(ncid, varid_time, '_FillValue', -9999.0_dp)

        ! Layer:
            ! Define the variable
            status = nf90_def_var(ncid, 'Layer', NF90_DOUBLE, dimids(3), varid_layer)
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_layer, 'long_name', 'Layer')
            status = nf90_put_att(ncid, varid_layer, 'units', 'gWW m-2')
            status = nf90_put_att(ncid, varid_layer, 'positive', 'up')
            status = nf90_put_att(ncid, varid_layer, 'axis', 'Z')
            status = nf90_put_att(ncid, varid_layer, 'cartesian_axis', 'Z')
            status = nf90_put_att(ncid, varid_layer, '_FillValue', -9999.0_dp)
        
        ! lath :
            ! Define the variable
            status = nf90_def_var(ncid, 'lath', NF90_DOUBLE, dimids(2), varid_lath)    
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_lath, 'long_name', 'Latitude')
            status = nf90_put_att(ncid, varid_lath, 'Standard_name', 'latitude')
            status = nf90_put_att(ncid, varid_lath, 'units', 'degrees_north')
            status = nf90_put_att(ncid, varid_lath, 'axis', "Y")
            status = nf90_put_att(ncid, varid_lath, '_FillValue', -9999.0_dp)     
        
        ! lonh :
            ! Define the variable
            status = nf90_def_var(ncid, 'lonh', NF90_DOUBLE, dimids(1), varid_longh)
            ! Add a attributes: 
            status = nf90_put_att(ncid, varid_longh, 'long_name', 'Longitude')
            status = nf90_put_att(ncid, varid_longh, 'Standard_name', 'longitude')
            status = nf90_put_att(ncid, varid_longh, 'units', 'degrees_east')
            status = nf90_put_att(ncid, varid_longh, 'axis', "X")
            status = nf90_put_att(ncid, varid_longh, '_FillValue', -9999.0_dp) 

        status = nf90_enddef(ncid)  ! End the definitions mode: enter data mode


        ! Define valuse for each dimension : -----------------------------------------------------------
        ! get values from COBALT hgrid files       
        Time_dim_val = (/(i, i=1, Ntime, 1)/)
        call readgrid1D(dir_FEISTY_IC_YC, 'Layer', Nlayer, layer_dim_val) ! Use layer from this file (I cannot get the actual layer depth from the grid files generated for each location)
        ! Forcing long and lat from ocean_hgrid.nc (new method): 
        call readgrid1D(dir_loc_grid, 'y',  Nlath,  lath_dim_val)
        call readgrid1D(dir_loc_grid, 'x', Nlongh, longh_dim_val)

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

    subroutine add_Diag_nc(ncid, dimids, varname, long_name, var, Ntime, Nlayer, Nlath, Nlongh)
        character(LEN=*), intent(in) :: varname
        character(LEN=*), intent(in) :: long_name
        integer, intent(in) :: dimids(4)
        integer, intent(in) :: ncid, Ntime, Nlayer, Nlath, Nlongh
        real(dp), dimension(Ntime, Nlath, Nlongh), intent(in) :: var
        real(dp), dimension(Nlongh, Nlath, Ntime) ::  var_reshaped
        integer :: varid
        integer :: status

        ! Reshaping variable before saving for COBALT ouput:
        var_reshaped = RESHAPE(var, SHAPE(var_reshaped), ORDER = (/3, 2, 1/))

        ! Put opened netcdf into definition mode: 
        status = nf90_redef(ncid)

        ! Define the variable
        status = nf90_def_var(ncid, varname, NF90_DOUBLE, dimids([1,2,4]), varid)
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
        status = nf90_put_var(ncid, varid, var_reshaped(1:Nlongh, 1:Nlath, 1:Ntime)) !, &
                            !   start = (/1,      1,     1    ,  (Ntime-1) /), &
                            !   count = (/Nlongh, Nlath, Nlayer, 1         /))
        if (status /= NF90_NOERR) then
            print *, "Error in nf90_put_var: " , trim(varname), " in add_tracer_nc "
            print *, trim(nf90_strerror(status))
            STOP
        end if        
    end subroutine add_Diag_nc

 
end module GetNetCDFinf