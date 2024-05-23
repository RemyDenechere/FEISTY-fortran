module GetNetCDFinf
    use Parameters
    use Structure 
    use netcdf 

    implicit none 

    contains 

    subroutine Initialisation(Spinup, Var, Ntime, Nlayer, Nlath, Nlongh, Data_F_ini, Data, &
                              DataTemp, Datadet, Datadzm, DataZM, Datadzl, DataZL)
        logical, intent(in) :: Spinup
        integer, intent(inout) :: Ntime, Nlayer, Nlath, Nlongh
        type(Structure_group) :: Var
        type(ini_fish_data), intent(inout) :: Data_F_ini
        type(Save_structure4D), intent(inout) :: Data
        real(dp), dimension(:, :, :, :), allocatable, intent(inout) ::  DataTemp, &
                                                                        Datadzm, DataZM, &
                                                                        Datadzl, DataZL, &
                                                                        Datadet

        CALL griddims4D(dir_Temp, Ntime, Nlayer, Nlath, Nlongh, Var)   
        CALL load_forcing_data(Ntime, Nlayer, Nlath, Nlongh, DataTemp, Datadet, Datadzm, DataZM, Datadzl, DataZL)
        Call load_IC_fish(Spinup, Nlayer, Nlath, Nlongh, Data_F_ini)

        if (Spinup) then 
            Ntime = (Ntime-1) * Year_2_Spinup
        else 
            Ntime = Ntime -1
        end if
        ! Save lat long, and time in structure: 
        Var%Ntime  = Ntime
        Var%Nlayer = Nlayer
        Var%Nlath  = Nlath
        Var%Nlongh = Nlongh 

        CALL init_save_data4D(Data, Ntime, Nlayer, Nlath, Nlongh)
        
        
        ! Individual Mass (g) geometric mean for each group 
        Var%Sf%w = 10.0**((log10(0.001)+log10(0.5))/2)
        Var%Sp%w = 10.0**((log10(0.001)+log10(0.5))/2)
        Var%Sd%w = 10.0**((log10(0.001)+log10(0.5))/2)
        Var%Mf%w = 10.0**((log10(0.5)+log10(250.0))/2) 
        Var%Mp%w = 10.0**((log10(0.5)+log10(250.0))/2) 
        Var%Md%w = 10.0**((log10(0.5)+log10(250.0))/2) 
        Var%Lp%w = 10.0**((log10(250.0)+log10(125000.0))/2)
        Var%Ld%w = 10.0**((log10(250.0)+log10(125000.0))/2)
    end subroutine Initialisation
    


    subroutine save_data(Spinup, that, Ntime, Nlayer, Nlath, Nlongh)
        logical, intent(in) :: Spinup
        type(Save_structure4D) :: that
        integer, intent(in) :: Ntime, Nlayer, Nlath, Nlongh
        integer :: i
    
        if (Spinup) then 
            ! Write each variable to a separate NetCDF file : ---------------------------
            call write_nc_file3D(Dir_IniBE, 'BE', that%BE(Ntime, 1:Nlayer, 1:Nlath, 1:Nlongh),  Nlayer, Nlath, Nlongh)
            call write_nc_file3D(Dir_IniSf, 'Sf', that%Sf(Ntime, 1:Nlayer, 1:Nlath, 1:Nlongh),  Nlayer, Nlath, Nlongh)
            call write_nc_file3D(Dir_IniSp, 'Sp', that%Sp(Ntime, 1:Nlayer, 1:Nlath, 1:Nlongh),  Nlayer, Nlath, Nlongh)
            call write_nc_file3D(Dir_IniSd, 'Sd', that%Sd(Ntime, 1:Nlayer, 1:Nlath, 1:Nlongh),  Nlayer, Nlath, Nlongh)
            call write_nc_file3D(Dir_IniMf, 'Mf', that%Mf(Ntime, 1:Nlayer, 1:Nlath, 1:Nlongh),  Nlayer, Nlath, Nlongh)
            call write_nc_file3D(Dir_IniMp, 'Mp', that%Mp(Ntime, 1:Nlayer, 1:Nlath, 1:Nlongh),  Nlayer, Nlath, Nlongh)
            call write_nc_file3D(Dir_IniMd, 'Md', that%Md(Ntime, 1:Nlayer, 1:Nlath, 1:Nlongh),  Nlayer, Nlath, Nlongh)
            call write_nc_file3D(Dir_IniLp, 'Lp', that%Lp(Ntime, 1:Nlayer, 1:Nlath, 1:Nlongh),  Nlayer, Nlath, Nlongh)
            call write_nc_file3D(Dir_IniLd, 'Ld', that%Ld(Ntime, 1:Nlayer, 1:Nlath, 1:Nlongh),  Nlayer, Nlath, Nlongh)
            
            if (Spinup_Time_Serie) then 
                ! Write each variable to a separate NetCDF file : ---------------------------
                call write_nc_file4D('../output/' // trim(exp) // '_BE_bio_Spinup_Time_Serie.nc', &
                                        'BE', that%BE, Ntime, Nlayer, Nlath, Nlongh)
                call write_nc_file4D('../output/' // trim(exp) // '_Sf_bio_Spinup_Time_Serie.nc', &
                                        'Sf', that%Sf, Ntime, Nlayer, Nlath, Nlongh)
                call write_nc_file4D('../output/' // trim(exp) // '_Sp_bio_Spinup_Time_Serie.nc', &
                                        'Sp', that%Sp, Ntime, Nlayer, Nlath, Nlongh)
                call write_nc_file4D('../output/' // trim(exp) // '_Sd_bio_Spinup_Time_Serie.nc', &
                                        'Sd', that%Sd, Ntime, Nlayer, Nlath, Nlongh)
                call write_nc_file4D('../output/' // trim(exp) // '_Mf_bio_Spinup_Time_Serie.nc', & 
                                        'Mf', that%Mf, Ntime, Nlayer, Nlath, Nlongh)
                call write_nc_file4D('../output/' // trim(exp) // '_Mp_bio_Spinup_Time_Serie.nc', &
                                        'Mp', that%Mp, Ntime, Nlayer, Nlath, Nlongh)
                call write_nc_file4D('../output/' // trim(exp) // '_Md_bio_Spinup_Time_Serie.nc', &
                                        'Md', that%Md, Ntime, Nlayer, Nlath, Nlongh)
                call write_nc_file4D('../output/' // trim(exp) // '_Lp_bio_Spinup_Time_Serie.nc', &
                                        'Lp', that%Lp, Ntime, Nlayer, Nlath, Nlongh)
                call write_nc_file4D('../output/' // trim(exp) // '_Ld_bio_Spinup_Time_Serie.nc', &
                                        'Ld', that%Ld, Ntime, Nlayer, Nlath, Nlongh)
                call write_nc_file4D('../output/' // trim(exp) // '_dZm_Spinup_Time_Serie.nc', &
                                        'dZm', that%Zcons_VS_dZm, Ntime, Nlayer, Nlath, Nlongh)
                call write_nc_file4D('../output/' // trim(exp) // '_dZl_Spinup_Time_Serie.nc', &
                                        'dZl', that%Zcons_VS_dZl, Ntime, Nlayer, Nlath, Nlongh)
            end if 
            if(Initial_Condition_generic_FEISTY) then 
                call FEISTY_Save_outputs(Spinup, that, Ntime, Nlayer, Nlath, Nlongh) 
            end if 

        else
            ! Write each variable to a separate NetCDF file : ---------------------------
            call write_nc_file4D('../output/' // trim(exp) // '_BE_bio.nc', 'BE', that%BE, Ntime, Nlayer, Nlath, Nlongh)
            call write_nc_file4D('../output/' // trim(exp) // '_Sf_bio.nc', 'Sf', that%Sf, Ntime, Nlayer, Nlath, Nlongh)
            call write_nc_file4D('../output/' // trim(exp) // '_Sp_bio.nc', 'Sp', that%Sp, Ntime, Nlayer, Nlath, Nlongh)
            call write_nc_file4D('../output/' // trim(exp) // '_Sd_bio.nc', 'Sd', that%Sd, Ntime, Nlayer, Nlath, Nlongh)
            call write_nc_file4D('../output/' // trim(exp) // '_Mf_bio.nc', 'Mf', that%Mf, Ntime, Nlayer, Nlath, Nlongh)
            call write_nc_file4D('../output/' // trim(exp) // '_Mp_bio.nc', 'Mp', that%Mp, Ntime, Nlayer, Nlath, Nlongh)
            call write_nc_file4D('../output/' // trim(exp) // '_Md_bio.nc', 'Md', that%Md, Ntime, Nlayer, Nlath, Nlongh)
            call write_nc_file4D('../output/' // trim(exp) // '_Lp_bio.nc', 'Lp', that%Lp, Ntime, Nlayer, Nlath, Nlongh)
            call write_nc_file4D('../output/' // trim(exp) // '_Ld_bio.nc', 'Ld', that%Ld, Ntime, Nlayer, Nlath, Nlongh)
            call write_nc_file4D('../output/' // trim(exp) // '_dZm.nc', 'dZm', that%Zcons_VS_dZm, Ntime, Nlayer, Nlath, Nlongh)
            call write_nc_file4D('../output/' // trim(exp) // '_dZl.nc', 'dZl', that%Zcons_VS_dZl, Ntime, Nlayer, Nlath, Nlongh)
        end if 
    end subroutine save_data 

    subroutine write_nc_file4D(filename, varname, var, Ntime, Nlayer, Nlath, Nlongh)
        character(*), intent(in) :: filename, varname
        integer, intent(in) :: Ntime, Nlayer, Nlath, Nlongh
        real(dp), dimension(Ntime, Nlayer, Nlath, Nlongh), intent(in) :: var
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
        status = nf90_def_var(ncid, varname, NF90_REAL, dimids, varid)

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
        real(dp), dimension(Nlayer, Nlath, Nlongh), intent(in) :: var
        integer :: ncid, dimids(3), varid
        integer :: status

        ! Create the NetCDF file
        status = nf90_create(filename, NF90_CLOBBER, ncid)
        
        ! Define the dimensions
        status = nf90_def_dim(ncid, 'Layer' , Nlayer , dimids(1))
        status = nf90_def_dim(ncid, 'Lath'  , Nlath  , dimids(2))
        status = nf90_def_dim(ncid, 'Longh' , Nlongh , dimids(3))

        ! Define the variable
        status = nf90_def_var(ncid, varname, NF90_REAL, dimids, varid)

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
    !:======================================================================  
    subroutine Get_Environental_data(this, DataTemp, Datadet, Datadzm, DataZM, Datadzl, DataZL, &
                                    itime, ilayer, ilath, ilongh)
        type(Structure_group), intent(inout) :: this
        integer :: itime, ilayer, ilath, ilongh
        real(dp), dimension(:, :, :, :), allocatable, intent(inout) ::  DataTemp, &
                                                                        Datadzm, DataZM, &
                                                                        Datadzl, DataZL, &
                                                                        Datadet
        
        this%Temp = DataTemp(ilongh, ilath, ilayer, itime)
        this%Mz%B = DataZM(ilongh, ilath, ilayer, itime)  * convers_zm
        this%dzm  = Datadzm(ilongh, ilath, ilayer, itime) * convers_dZm
        this%Lz%B = DataZL(ilongh, ilath, ilayer, itime)  * convers_zm
        this%dzl  = Datadzl(ilongh, ilath, ilayer, itime) * convers_dZm
        this%det  = Datadet(ilongh, ilath, ilayer, itime)

        
        
    end subroutine Get_Environental_data


    !:====================================================================== 
    ! Load all the imput values to force the model
    !:======================================================================  
    subroutine load_forcing_data(Ntime, Nlayer, Nlath, Nlongh, DataTemp, &
                                 Datadet, Datadzm, DataZM, Datadzl, DataZL)
        ! Declare variables
        real(dp), dimension(:, :, :, :), allocatable, intent(inout) ::  DataTemp, &
                                                                        Datadzm, DataZM, &
                                                                        Datadzl, DataZL, &
                                                                        Datadet
        integer :: Ntime, Nlayer, Nlath, Nlongh

        ! Get the input grid data to force the model: 
            CALL readgrid4D(dir_Temp, var_Temp, Ntime, Nlayer, Nlath, Nlongh, DataTemp)
            CALL readgrid4D(dir_zm, var_zm, Ntime, Nlayer, Nlath, Nlongh, DataZM)
            CALL readgrid4D(dir_dzm, var_dzm, Ntime, Nlayer, Nlath, Nlongh, Datadzm)
            CALL readgrid4D(dir_zl, var_zl, Ntime, Nlayer, Nlath, Nlongh, DataZL)
            CALL readgrid4D(dir_dzl, var_dzl, Ntime, Nlayer, Nlath, Nlongh, Datadzl)
            CALL readgrid4D(dir_det, var_det, Ntime, Nlayer, Nlath, Nlongh, Datadet)
    end subroutine load_forcing_data


    !:====================================================================== 
    ! Load all the Spinup Initial condition to force the FEISTY
    !:======================================================================  
    subroutine load_IC_fish(Spinup, Nlayer, Nlath, Nlongh, this)
        
        type(ini_fish_data) :: this
        logical, intent(in) :: Spinup
        integer, intent(in) :: Nlayer, Nlath, Nlongh

        if (Spinup .eqv. .false.) then 
            CALL readgrid3D(dir_IniSf, 'Sf', Nlayer, Nlath, Nlongh, this%IniSf)
            CALL readgrid3D(dir_IniSp, 'Sp', Nlayer, Nlath, Nlongh, this%IniSp)
            CALL readgrid3D(dir_IniSd, 'Sd', Nlayer, Nlath, Nlongh, this%IniSd)
            CALL readgrid3D(dir_IniMf, 'Mf', Nlayer, Nlath, Nlongh, this%IniMf)
            CALL readgrid3D(dir_IniMp, 'Mp', Nlayer, Nlath, Nlongh, this%IniMp)
            CALL readgrid3D(dir_IniMd, 'Md', Nlayer, Nlath, Nlongh, this%IniMd)
            CALL readgrid3D(dir_IniLp, 'Lp', Nlayer, Nlath, Nlongh, this%IniLp)
            CALL readgrid3D(dir_IniLd, 'Ld', Nlayer, Nlath, Nlongh, this%IniLd)
            CALL readgrid3D(dir_IniBE, 'BE', Nlayer, Nlath, Nlongh, this%IniBE)
        end if
    end subroutine load_IC_fish


    !:====================================================================== 
    ! Get the dimension of the netCDF 4D gridfile
    !:======================================================================  
    subroutine griddims4D(dir, Ntime, Nlayer, Nlath, Nlongh, this)
        type(Structure_group), intent(inout) :: this
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
    end subroutine griddims4D

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

    subroutine readgrid1D(dir, varname, Dim1, values)
        character(LEN=*), intent(in) :: dir, varname
        integer, intent(in) :: Dim1
        real(dp), dimension(Dim1), intent(inout) :: values
        integer :: ierr, vartype, nAtts, ncid, varid
        integer, dimension(3) :: ndims
        print*, varname

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
    end subroutine readgrid1D

    subroutine FEISTY_Save_outputs(Spinup, that, Ntime, Nlayer, Nlath, Nlongh)
        logical, intent(in) :: Spinup
        type(Save_structure4D) :: that
        integer, intent(in) :: Ntime, Nlayer, Nlath, Nlongh
        character(LEN=280) :: filename = "../output/FEISTY_2023_10_spinup_subset.nc"
        integer(4) :: ncid, dimids(4)
        integer :: i,j,k,l

        call init_tracer_INPUT_nc(filename, ncid, Ntime, Nlayer, Nlath, Nlongh, dimids)

        call add_tracer_INPUT_nc(ncid, dimids, "Sf_B", "Small forage fish biomass        ", that%SF, Ntime, Nlayer, Nlath, Nlongh)
        call add_tracer_INPUT_nc(ncid, dimids, "Mf_B", "Medium forage fish biomass       ", that%MF, Ntime, Nlayer, Nlath, Nlongh)
        call add_tracer_INPUT_nc(ncid, dimids, "Sp_B", "Small large pelagic fish biomass ", that%SP, Ntime, Nlayer, Nlath, Nlongh)
        call add_tracer_INPUT_nc(ncid, dimids, "Mp_B", "Medium large pelagic fish biomass", that%MP, Ntime, Nlayer, Nlath, Nlongh)
        call add_tracer_INPUT_nc(ncid, dimids, "Lp_B", "Large pelagic fish biomass       ", that%LP, Ntime, Nlayer, Nlath, Nlongh)
        call add_tracer_INPUT_nc(ncid, dimids, "Sd_B", "Small demersal fish biomass      ", that%SD, Ntime, Nlayer, Nlath, Nlongh)
        call add_tracer_INPUT_nc(ncid, dimids, "Md_B", "Medium demersal fish biomass     ", that%MD, Ntime, Nlayer, Nlath, Nlongh)
        call add_tracer_INPUT_nc(ncid, dimids, "Ld_B", "Large demersal fish biomass      ", that%LD, Ntime, Nlayer, Nlath, Nlongh)
        call add_tracer_INPUT_nc(ncid, dimids, "BE_B", "Benthic invertebrate biomass     ", that%BE, Ntime, Nlayer, Nlath, Nlongh)

        call end_tracer_INPUT_nc(ncid)

    end subroutine FEISTY_Save_outputs


    subroutine init_tracer_INPUT_nc(filename, ncid, Ntime, Nlayer, Nlath, Nlongh, dimids)
        character(LEN = 280), intent(in) :: filename 
        integer, intent(inout) :: ncid, dimids(4)
        integer, intent(in) :: Ntime, Nlayer, Nlath, Nlongh
        integer :: status
        integer :: Interface = 76, latq = 5, lonq = 5
        integer :: varid_time, varid_layer, varid_lath, varid_longh
        integer :: i
        real(dp), dimension(1) :: time_dim_val
        real(dp), dimension(Nlayer) :: layer_dim_val
        real(dp), dimension(Nlath)  :: lath_dim_val
        real(dp), dimension(Nlongh) :: longh_dim_val

        ! Create the NetCDF file
        status = nf90_create(filename, NF90_CLOBBER, ncid)
        if (status /= NF90_NOERR) then
            print *, "Error opening " , trim(filename), " in init_tracer_INPUT_nc"
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
        !status = nf90_def_dim(ncid, 'lonq' , lonq  , dimids(3))
        !status = nf90_def_dim(ncid, 'latq' , latq  , dimids(2))
        !status = nf90_def_dim(ncid, 'Interface' , Interface, dimids(1))

        ! Put opened netcdf into definition mode: 
        status = nf90_redef(ncid)

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
            status = nf90_put_att(ncid, varid_layer, 'units', 'gWW m-3')
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

        ! End the definitions mode: enter data mode
        status = nf90_enddef(ncid)

        ! Write the variable data: get values from COBALT
        call readgrid1D(dir_COBALT_IC, 'Time',  1,  Time_dim_val)
        call readgrid1D(dir_COBALT_IC, 'Layer', Nlayer, layer_dim_val)
        call readgrid1D(dir_COBALT_IC, 'lath',  Nlath,  lath_dim_val)       
        call readgrid1D(dir_COBALT_IC, 'lonh', Nlongh, longh_dim_val)

        status = nf90_put_var(ncid, varid_Time, 1.0)
        status = nf90_put_var(ncid, varid_layer, layer_dim_val)
        status = nf90_put_var(ncid, varid_lath,  lath_dim_val)
        status = nf90_put_var(ncid, varid_longh, longh_dim_val)
    end subroutine init_tracer_INPUT_nc

    subroutine end_tracer_INPUT_nc(ncid)
        integer, intent(in) :: ncid
        integer :: status

        ! Close the file
        status = nf90_close(ncid)
        if (status /= NF90_NOERR) then
            print *, "Error clossing ncdf in end_tracer_INPUT_nc"
            print *, trim(nf90_strerror(status))
            STOP
        end if
    end subroutine end_tracer_INPUT_nc


    subroutine add_tracer_INPUT_nc(ncid, dimids, varname, long_name, var, Ntime, Nlayer, Nlath, Nlongh)
        character(LEN=*), intent(in) :: varname
        character(LEN=33), intent(in) ::  long_name
        integer, intent(in) :: dimids(4)
        integer, intent(in) :: ncid, Ntime, Nlayer, Nlath, Nlongh
        real(dp), dimension(Nlongh, Nlath, Nlayer, Ntime), intent(in) :: var
        integer :: varid
        integer :: status

        ! Put opened netcdf into definition mode: 
        status = nf90_redef(ncid)

        ! Define the variable
        status = nf90_def_var(ncid, varname, NF90_DOUBLE, dimids, varid)
        if (status /= NF90_NOERR) then
            print *, "Error Def Var: ", trim(varname)
            print *, trim(nf90_strerror(status))
            STOP
        end if
        
        ! Add a attributes: 
        status = nf90_put_att(ncid, varid, "long_name", trim(long_name))
        status = nf90_put_att(ncid, varid, 'units', 'gWW m-3')
        status = nf90_put_att(ncid, varid, 'checksum', "               0")
        status = nf90_put_att(ncid, varid, '_FillValue', -9999.0_dp)

        ! End the definitions mode: enter data mode
        status = nf90_enddef(ncid)

        ! Write the variable data
        status = nf90_put_var(ncid, varid, var(1:Nlongh, 1:Nlath, 1:Nlayer, Ntime)) !, &
                            !   start = (/1,      1,     1    ,  (Ntime-1) /), &
                            !   count = (/Nlongh, Nlath, Nlayer, 1         /))
        if (status /= NF90_NOERR) then
            print *, "Error in nf90_put_var: " , trim(varname), " in add_tracer_INPUT_nc "
            print *, trim(nf90_strerror(status))
            STOP
        end if        
    end subroutine add_tracer_INPUT_nc

end module GetNetCDFinf