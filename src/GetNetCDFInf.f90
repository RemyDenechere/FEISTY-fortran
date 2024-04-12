module GetNetCDFinf
    use Parameters
    use Structure 
    use netcdf 

    implicit none 

    contains 

    subroutine Initialisation(Spinup, Var, Nspace, Ntime, Data_F_ini, Data, &
                              DataTp, DataTb, Datadet, Datadzm, DataZM, Datadzl, DataZL)
        logical, intent(in) :: Spinup
        integer, intent(inout) :: Nspace, Ntime
        type(Structure_group) :: Var
        type(ini_fish_data), intent(inout) :: Data_F_ini
        type(Save_structure2D), intent(inout) :: Data
        real(dp), dimension(:, :), allocatable, intent(inout) ::DataTp, DataTb, &
                                                                Datadet, &
                                                                Datadzm, DataZM, &
                                                                Datadzl, DataZL

        CALL griddims2D(dir_Tb, Nspace, Ntime, var)                                                        
        CALL ini_input2D(Nspace, Ntime, DataTp, DataTb, Datadet, Datadzm, DataZM, Datadzl, DataZL)
        Call ini_input_fish(Spinup, Nspace, Data_F_ini)
        CALL init_save_data2D(Data, Nspace)
        
        
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
    
    subroutine save_data(Spinup, that, Nspace, Count_MNT)
        logical, intent(in) :: Spinup
        type(Save_structure2D) :: that
        integer, intent(in) :: Nspace, Count_MNT
        integer :: i
    
        if (Spinup) then 

            ! Write each variable to a separate NetCDF file : ---------------------------
            call write_nc_file1D(Dir_IniBE, 'BE', that%BE(1:Nspace, Nmonth), Nspace)
            call write_nc_file1D(Dir_IniSf, 'Sf', that%Sf(1:Nspace, Nmonth), Nspace)
            call write_nc_file1D(Dir_IniSp, 'Sp', that%Sp(1:Nspace, Nmonth), Nspace)
            call write_nc_file1D(Dir_IniSd, 'Sd', that%Sd(1:Nspace, Nmonth), Nspace)
            call write_nc_file1D(Dir_IniMf, 'Mf', that%Mf(1:Nspace, Nmonth), Nspace)
            call write_nc_file1D(Dir_IniMp, 'Mp', that%Mp(1:Nspace, Nmonth), Nspace)
            call write_nc_file1D(Dir_IniMd, 'Md', that%Md(1:Nspace, Nmonth), Nspace)
            call write_nc_file1D(Dir_IniLp, 'Lp', that%Lp(1:Nspace, Nmonth), Nspace)
            call write_nc_file1D(Dir_IniLd, 'Ld', that%Ld(1:Nspace, Nmonth), Nspace)
            
        else
            ! Write each variable to a separate NetCDF : ---------------------------
            call write_nc_file2D('../output/' // trim(exp) //  'BE_bio.nc', 'BE', that%BE, Nspace, Nmonth)
            call write_nc_file2D('../output/' // trim(exp) //  'Sf_bio.nc', 'Sf', that%Sf, Nspace, Nmonth)
            call write_nc_file2D('../output/' // trim(exp) //  'Sp_bio.nc', 'Sp', that%Sp, Nspace, Nmonth)
            call write_nc_file2D('../output/' // trim(exp) //  'Sd_bio.nc', 'Sd', that%Sd, Nspace, Nmonth)
            call write_nc_file2D('../output/' // trim(exp) //  'Mf_bio.nc', 'Mf', that%Mf, Nspace, Nmonth)
            call write_nc_file2D('../output/' // trim(exp) //  'Mp_bio.nc', 'Mp', that%Mp, Nspace, Nmonth)
            call write_nc_file2D('../output/' // trim(exp) //  'Md_bio.nc', 'Md', that%Md, Nspace, Nmonth)
            call write_nc_file2D('../output/' // trim(exp) //  'Lp_bio.nc', 'Lp', that%Lp, Nspace, Nmonth)
            call write_nc_file2D('../output/' // trim(exp) //  'Ld_bio.nc', 'Ld', that%Ld, Nspace, Nmonth)
            call write_nc_file2D('../output/' // trim(exp) //  'dZm.nc', 'dZm', that%Zcons_VS_dZm, Nspace, Nmonth)
            call write_nc_file2D('../output/' // trim(exp) //  'dZl.nc', 'dZl', that%Zcons_VS_dZl, Nspace, Nmonth)
        end if 
    end subroutine save_data 

    subroutine write_nc_file2D(filename, varname, var, Nspace, Ntime)
        character(*), intent(in) :: filename, varname
        integer, intent(in) :: Nspace, Ntime
        real(dp), dimension(Nspace, Ntime), intent(in) :: var
        integer :: ncid, dimids(2), varid
        integer :: status

        ! Create the NetCDF file
        status = nf90_create(filename, NF90_CLOBBER, ncid)
        
        ! Define the dimensions
        status = nf90_def_dim(ncid, 'Space', Nspace, dimids(1))
        status = nf90_def_dim(ncid, 'Time' , Ntime , dimids(2))

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
    end subroutine write_nc_file2D
    

    subroutine write_nc_file1D(filename, varname, var, Nspace)
        character(*), intent(in) :: filename, varname
        integer, intent(in) :: Nspace
        real(dp), dimension(Nspace), intent(in) :: var
        integer :: ncid, dimids(1), varid
        integer :: status

        ! Create the NetCDF file
        status = nf90_create(filename, NF90_CLOBBER, ncid)
        
        ! Define the dimensions
        status = nf90_def_dim(ncid, 'Space', Nspace, dimids(1))

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
    end subroutine write_nc_file1D

    !:====================================================================== 
    ! Get the input values for the given lat long and time 
    !:======================================================================  
    subroutine Get_Environental_data2D(this, DataTp, DataTb, Datadet, Datadzm, DataZM, Datadzl, DataZL, ispace, itime)
        type(Structure_group), intent(inout) :: this
        integer :: ispace, itime
        real(dp), dimension(:, :), allocatable, intent(inout) ::DataTp, DataTb, &
                                                                Datadzm, Datadet, &
                                                                DataZM, &
                                                                Datadzl, DataZL
        
        if (diagnostic) then 
            this%Tp =  20.588572332253598
            this%Tb = 0.0
            this%det = 0.0
            this%Mz%B = 5.8770968308468755E-005 * 6.625*12.01*9.0
            this%dzm = 0.0
            this%Lz%B = 3.1586583957953118E-005 * 6.625*12.01*9.0
            this%dzl = 0.0
        else
            this%Tp =  DataTp(ispace, itime)
            this%Tb = DataTb(ispace, itime)
            this%det = Datadet(ispace, itime) * convers_det
            this%Mz%B = DataZM(ispace, itime) * convers_zm
            this%dzm = Datadzm(ispace, itime)   * convers_dZm
            this%Lz%B = DataZL(ispace, itime) * convers_zm
            this%dzl = Datadzl(ispace, itime)   * convers_dZm
        end if 
        
    end subroutine Get_Environental_data2D


    !:====================================================================== 
    ! Load all the imput values to force the model
    !:======================================================================  
    subroutine ini_input2D(Nspace, Ntime, DataTp, DataTb, Datadet, Datadzm, DataZM, Datadzl, DataZL)
        ! Declare variables
        real(dp), dimension(:, :), allocatable, intent(inout) :: DataTp, DataTb, &
                                                                Datadzm, Datadet, &
                                                                DataZM, &
                                                                Datadzl, DataZL
        integer :: Nspace, Ntime

        ! Get the input grid data to force the model: 
        if (diagnostic) then 
            print*, " checkpoint #1"
            CALL readgrid2D(dir_Tb, 1, Nspace, Ntime, DataTb)
            print*, trim(dir_Tb), " loaded"
            CALL readgrid2D(dir_Tp, 1, Nspace, Ntime, DataTp)
            print*, trim(dir_Tp), " loaded"
            CALL readgrid2D(dir_zm, 1, Nspace, Ntime, DataZM)
            print*, trim(dir_zm), " loaded"
            CALL readgrid2D(dir_dzm, 1, Nspace, Ntime, Datadzm)
            print*, trim(dir_dzm), " loaded"
            CALL readgrid2D(dir_det, 1, Nspace, Ntime, Datadet)
            print*, trim(dir_det), " loaded"
            CALL readgrid2D(dir_zl, 1, Nspace, Ntime, DataZL)
            print*, trim(dir_zl), " loaded"
            CALL readgrid2D(dir_dzl, 1, Nspace, Ntime, Datadzl)
            print*, trim(dir_dzl), " loaded"
        end if 

    end subroutine ini_input2D


    !:====================================================================== 
    ! Load all the Spinup Initial condition to force the FEISTY
    !:======================================================================  
    subroutine ini_input_fish(Spinup, Nspace, this)
        type(ini_fish_data) :: this
        logical, intent(in) :: Spinup
        integer, intent(in) :: Nspace

        if (Spinup .eqv. .false.) then 
            CALL readgrid(dir_IniSf, 1, Nspace, this%IniSf)
            CALL readgrid(dir_IniSp, 1, Nspace, this%IniSp)
            CALL readgrid(dir_IniSd, 1, Nspace, this%IniSd)
            CALL readgrid(dir_IniMf, 1, Nspace, this%IniMf)
            CALL readgrid(dir_IniMp, 1, Nspace, this%IniMp)
            CALL readgrid(dir_IniMd, 1, Nspace, this%IniMd)
            CALL readgrid(dir_IniLp, 1, Nspace, this%IniLp)
            CALL readgrid(dir_IniLd, 1, Nspace, this%IniLd)
            CALL readgrid(dir_IniBE, 1, Nspace, this%IniBE)
        end if

        CALL readgrid(dir_H, 1, Nspace, this%H)

    end subroutine ini_input_fish

    !:====================================================================== 
    ! Get the dimension of the netCDF 3D gridfile
    !:======================================================================  
    subroutine griddims2D(dir, Nspace, Ntime, this)
        type(Structure_group), intent(inout) :: this
        character(LEN=280), intent(in) :: dir
        integer, intent(inout) :: Nspace, Ntime
        integer :: ncid
        character(LEN=250) :: xname, yname
        integer :: ierr
        
        ! Open NetCDF: --------------------------------------------
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, "Error opening file: ", trim(dir)
            STOP
        end if
        
        !inquire about the dimensions: ----------------------------
        ierr = nf90_inquire_dimension(ncid, 1, xname, Nspace)
        if (ierr /= NF90_NOERR) then
            print *, "nf90_inquire_dimension ", trim(dir)
            STOP
        end if
        ierr = nf90_inquire_dimension(ncid, 2, yname, Ntime)
        if (ierr /= NF90_NOERR) then
            print *, "nf90_inquire_dimension ", trim(dir)
            STOP
        end if
        
        
        !Close netCDF file
        ierr = nf90_close(ncid)
        
        ! print outputs: -------------------------------------------
        print *, "------------------------------------"
        print*, "1st dimension =", trim(xname), "; length = ", Nspace
        print*, "2nd dimension =", trim(yname), "; length = ", Ntime
        print *, "------------------------------------"      
        
        ! Save lat long, and time in structure: 
        this%Nspace = Nspace
        this%Ntime = Ntime
    end subroutine griddims2D

    !:====================================================================== 
    ! read a netCDF gridfile
    !:======================================================================  
    subroutine readgrid2D(dir, varid, Nspace, Ntime, values)
        character(LEN=280), intent(in) :: dir
        integer, intent(in) :: Nspace, Ntime, varid 
        real(dp), dimension(:, :), allocatable, intent(inout) :: values
        character(LEN=250) :: varname
        integer :: ierr, vartype, ndims, nAtts, ncid
        ! Problem the function does not read the values 

        allocate(values(Nspace, Ntime))

        ! Open NetCDF: --------------------------------------------
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, "Error opening file: ", trim(dir)
            print *, NF90_STRERROR(ierr)
            stop
        end if
        
        ! Get the values of the coordinates and put them in xpos & ypos 
        ierr = nf90_inquire_variable(ncid, varid, varname, vartype, ndims, nAtts = nAtts)
        if (ierr /= NF90_NOERR) then
            print *, "nf90_inquire_variable ", trim(dir)
            print *, NF90_STRERROR(ierr)
            STOP
        end if

        ! Get values of the variable 
        ierr = nf90_get_var(ncid, varid, values)
        if (ierr /= NF90_NOERR) then
            print *, "nf90_get_var ", trim(dir)
            print *, NF90_STRERROR(ierr)
            STOP
        end if
        
        ! Close the netCDF files : ----------------------------------------------------------------
        ierr = nf90_close(ncid)
        if (ierr /= NF90_NOERR) then
            print *, "nf90_get_var ", trim(dir)
            print *, NF90_STRERROR(ierr)
            STOP
        end if
    end subroutine readgrid2D

    subroutine readgrid(dir, varid, Nspace, values)
        character(LEN=280), intent(in) :: dir
        integer, intent(in) :: Nspace, varid 
        real(dp), dimension(:), allocatable, intent(inout) :: values
        character(LEN=250) :: varname
        integer :: ierr, vartype, ndims, nAtts, ncid

        allocate(values(Nspace))
        
        ! Open NetCDF: --------------------------------------------
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, "Error opening file: ", trim(dir)
            stop
        end if
        
        ! Get the values of the coordinates and put them in xpos & ypos 
        ierr = nf90_inquire_variable(ncid, varid, varname, vartype, ndims, nAtts = nAtts)
        
        ! Get values of the variable 
        ierr = nf90_get_var(ncid, varid, values)
        
        ! Close the netCDF files : ----------------------------------------------------------------
        ierr = nf90_close(ncid)
    end subroutine readgrid

end module GetNetCDFinf