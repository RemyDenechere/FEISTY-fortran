module GetNetCDFinf
    use Parameters
    use Structure 
    use netcdf 

    implicit none 

    contains 
    
    subroutine write_nc_file(filename, varname, var, Nlat, Nlong, Ntime)
        character(*), intent(in) :: filename, varname
        integer, intent(in) :: Nlat, Nlong, Ntime
        real(dp), dimension(Nlat, Nlong, Ntime), intent(in) :: var
        integer :: ncid, dimids(3), varid
        integer :: status

        ! Create the NetCDF file
        status = nf90_create(filename, NF90_CLOBBER, ncid)
        
        ! Define the dimensions
        status = nf90_def_dim(ncid, 'Nlat', Nlat, dimids(1))
        status = nf90_def_dim(ncid, 'Nlong', Nlong, dimids(2))
        status = nf90_def_dim(ncid, 'Ntime', Ntime, dimids(3))

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
    end subroutine write_nc_file
    

    !:====================================================================== 
    ! Get the input values for the given lat long and time 
    !:======================================================================  
    subroutine Get_Environental_data(this, DataTp, DataTb, Datadz, Datadet, DataZM, ilat, ilong, itime)
        type(Structure_group), intent(inout) :: this
        integer :: ilat, ilong, itime
        real(dp), dimension(:, :, :), allocatable, intent(inout) :: DataTp, DataTb, &
                                                                    Datadz, Datadet, &
                                                                    DataZM
        
        this%Tp =  DataTp(ilat, ilong, itime)
        this%Tb = DataTb(ilat, ilong, itime)
        this%dz = Datadz(ilat, ilong, itime)
        this%det = Datadet(ilat, ilong, itime)
        this%Mz%B = DataZM(ilat, ilong, itime)
    end subroutine Get_Environental_data


    !:====================================================================== 
    ! Load all the imput values to force the model
    !:======================================================================  
    subroutine ini_input(DataTp, DataTb, Datadz, Datadet, DataZM)
        ! Declare variables
        real(dp), dimension(:, :, :), allocatable, intent(inout) :: DataTp, DataTb, &
                                                                    Datadz, Datadet, &
                                                                    DataZM
        integer :: ncid_Tb, ncid_Tp, ncid_zf, ncid_dz, ncid_det, ierr
        integer :: nvars_Tb, nvars_Tp, nvars_zf, nvars_dz, nvars_det
        integer ::  varid_Tb = 18, & 
                    varid_Tp = 18, & 
                    varid_zf = 37, &
                    varid_dz = 37, &
                    varid_det = 44
        integer :: varshape_Tb, varshape_Tp, varshape_zf, varshape_dz, varshape_det
        character(250) :: varname_Tb, varname_Tp, varname_zf, varname_dz, varname_det
        integer :: Nlat=0, Nlong=0, Ntime=0

        ! Get the input grid file: 
        CALL readgrid(dir_Tb, varid_Tb, Nlat, Nlong, Ntime, DataTp)
        CALL readgrid(dir_Tp, varid_Tp, Nlat, Nlong, Ntime, DataTb)
        CALL readgrid(dir_zf, varid_zf, Nlat, Nlong, Ntime, DataZM)
        CALL readgrid(dir_dz, varid_dz, Nlat, Nlong, Ntime, Datadz)
        CALL readgrid(dir_det, varid_det, Nlat, Nlong, Ntime, Datadet)      

    end subroutine ini_input

    !:====================================================================== 
    ! Get the dimension of the netCDF 3D gridfile
    !:======================================================================  
    subroutine griddims(dir, Nlat, Nlong, Ntime, this)
        type(Structure_group), intent(inout) :: this
        character(LEN=280), intent(in) :: dir
        integer, intent(inout) :: Nlat, Nlong, Ntime
        integer :: ncid
        character(LEN=250) :: xname, yname, zname
        integer :: ierr
        
        ! Open NetCDF: --------------------------------------------
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, "Error opening file: ", trim(dir)
            STOP
        end if
        
        !inquire about the dimensions:
        ierr = nf90_inquire_dimension(ncid, 1, xname, Nlat)
        ierr = nf90_inquire_dimension(ncid, 2, yname, Nlong)
        ierr = nf90_inquire_dimension(ncid, 3, zname, Ntime)
        
        !Close netCDF file
        ierr = nf90_close(ncid)
        
        ! print outputs: -------------------------------------------
        print *, "------------------------------------"
        print*, "1st dimension =", trim(xname), "; length = ", Nlat
        print*, "2nd dimension =", trim(yname), "; length = ", Nlong
        print*, "3rd dimension =", trim(zname), "; length = ", Ntime
        print *, "------------------------------------"      
        
        ! Save lat long, and time in structure: 
        this%Nlat = Nlat
        this%Nlong = Nlong
        this%Ntime = Ntime
    end subroutine griddims


    !:====================================================================== 
    ! read a netCDF gridfile
    !:======================================================================  
    subroutine readgrid(dir, varid, Nlat, Nlong, Ntime, values)
        character(LEN=280), intent(in) :: dir
        integer, intent(in) :: Nlat, Nlong, Ntime, varid 
        real(dp), dimension(:, :, :), allocatable, intent(inout) :: values
        character(LEN=250) :: varname
        integer :: ierr, vartype, ndims, nAtts, ncid

        allocate(values(Nlat, Nlong, Ntime))
        
        ! Open NetCDF: --------------------------------------------
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, "Error opening file: ", trim(dir)
            stop
        end if
        
        ! Get the values of the coordinates and put them in xpos & ypos 
        ierr = nf90_inquire_variable(ncid, varid, varname, vartype, ndims, nAtts = nAtts)
        
        ! Get values of the variable 
        ierr =  nf90_get_var(ncid, varid, values)
        
        ! Close the netCDF files : ----------------------------------------------------------------
        ierr = nf90_close(ncid)
        
    end subroutine readgrid

    
    !:====================================================================== 
    ! Get information about the variables in the netCDF
    !:======================================================================  
    subroutine GetVariableinfo(dir, varid, varname)
        character(280), intent(in) :: dir
        integer, intent(in) :: varid
        character(250), intent(inout) :: varname
        integer :: ncid
        integer :: nvars, vartype, ndims, nAtts
        integer :: ierr, i

        ! Open NetCDF: --------------------------------------------
        ierr = nf90_open(dir, NF90_NOWRITE, ncid)
        if (ierr /= NF90_NOERR) then
            print *, "Error opening file: ", trim(dir)
            stop
        else 
            print *, "Opened -", trim(dir)
        end if
        ! Get number of variables in the netCDF file----------------
        ierr = nf90_inquire(ncid, nvars)
        print*, "Number of variables :", nvars
        
        ! Do i = 1, 44
            ierr = nf90_inquire_variable(ncid, varid, varname, vartype, ndims, nAtts = nAtts)
            print *, "--------------------------------------------------"
            print *, "Variable ID                    : ", varid
            print *, "Variable Name                  : ", trim(varname)
            print *, "number of dimensions           : ", ndims
            print *, "Number of attributes           : ", nAtts
        ! end Do
        
        ! Close the netCDF files : ----------------------------------------------------------------
        ierr = nf90_close(ncid)
        
    end subroutine GetVariableinfo

end module GetNetCDFinf