program OpenNetCDFFiles
  use Parameters
  use netcdf
  use GetNetCDFInf
 ! mesozooC_zint_150m_2D.nc      pocToFloor_2_2D.nc   TEMP_mean_150m_2D.nc
 ! mesozoo_loss_zint_150m_2D.nc  TEMP_BOTTOM_2_2D.nc

  implicit none 

 ! Declare variables
  character(256) :: varname_Tb, varname_Tp, varname_zf, varname_dz, varname_det, varname_RM
  integer :: ncid_Tb, ncid_Tp, ncid_zf, ncid_dz, ncid_det, ierr, &
             nvars_Tb, nvars_Tp, nvars_zf, nvars_dz, nvars_det, &
             varid_Tb = 18, & 
             varid_Tp = 18, & 
             varid_zf = 37, &
             varid_dz = 37, &
             varid_det = 44, &
             varid_RM = 15, &
             varid = 1, &
             varshape_Tb, varshape_Tp, varshape_zf, varshape_dz, varshape_det, &
             Nlat, Nlong, Ntime, Nspace
  real(dp), dimension(:, :, :), allocatable :: Tb3D, Tp3D, zf3D, dz3D, det3D
  real(dp), dimension(:, :), allocatable :: Tb2D, Tp2D, zf2D, dz2D, det2D, RM
  integer, dimension(:), allocatable :: dimid_RM
  integer :: ndim_RM, i, j
  type(Structure_group) :: Var

  print *, "Netcdf version", trim(nf90_inq_libvers())

 ! Get basic information about the different imput files:-------------------
  CALL GetVariableInfo(dir_Tb, varid_Tb, varname_Tb)  
  CALL GetVariableInfo(dir_Tp, varid_Tp, varname_Tp)
  CALL GetVariableInfo(dir_zf, varid_zf, varname_zf) 
  CALL GetVariableInfo(dir_dz, varid_dz, varname_dz) 
  CALL GetVariableInfo(dir_det, varid_det, varname_det)


  ! Get the dimension for the input variable: (Same for all the imput files)
  CALL griddims3D(dir_Tb, Nlat, Nlong, Ntime, Var)
  ! CALL griddims2D(dir, Nspace, Ntime, this)
  ! print *, "Dimension of the Netcdf -------"
  ! print *, "Space grid  = ", Nspace
  ! print *, "Ntime       = ", Ntime
  
  ! ! Get the input from a 3D variable: ------------------------------- 
  CALL readgrid3D(dir_Tb,  varid_Tb, Nlat, Nlong, Ntime, Tb3D)
  CALL readgrid3D(dir_Tp,  varid_Tp, Nlat, Nlong, Ntime, Tp3D)
  CALL readgrid3D(dir_zf,  varid_zf, Nlat, Nlong, Ntime, zf3D)
  CALL readgrid3D(dir_dz,  varid_dz, Nlat, Nlong, Ntime, dz3D)
  CALL readgrid3D(dir_det, varid_det, Nlat, Nlong, Ntime, det3D)

  !  ! Get the input from a 2D variable: ------------------------------- 
  ! CALL readgrid2D(dir_Tb,  varid, Nspace, Ntime, Tb2D)
  ! CALL readgrid2D(dir_Tp,  varid, Nspace, Ntime, Tp2D)
  ! CALL readgrid2D(dir_zf,  varid, Nspace, Ntime, zf2D)
  ! CALL readgrid2D(dir_dz,  varid, Nspace, Ntime, dz2D)
  ! CALL readgrid2D(dir_det, varid, Nspace, Ntime, det2D)

  ! Get only the ocean id: REGION_MASK; ID = 15: ------------------------
  CALL GetVariableInfo(dir_Tb, varid_RM, varname_RM)
  CALL griddims2D(dir_Tb, Nspace, Ntime, Var)
  CALL readgrid2D(dir_zf, 15, Nspace, Ntime, RM)

  
  ! Read all the dimension in a netcdf files ----------------------------
  CALL Get_all_Variable_info(dir_Tp)

  ! Close the netCDF files : ----------------------------------------------------------------
  ierr = nf90_close(ncid_Tb)
  ierr = nf90_close(ncid_Tp)
  ierr = nf90_close(ncid_zf)
  ierr = nf90_close(ncid_dz)
  ierr = nf90_close(ncid_det)  

end program OpenNetCDFFiles
