program OpenNetCDFFiles
  use netcdf
  use GetNetCDFInf

  implicit none 

  ! Declare variables
  character(256) :: varname_Tb, varname_Tp, varname_zf, varname_dz, varname_det
  integer :: ncid_Tb, ncid_Tp, ncid_zf, ncid_dz, ncid_det, ierr, &
             nvars_Tb, nvars_Tp, nvars_zf, nvars_dz, nvars_det, &
             varid_Tb = 18, & 
             varid_Tp = 18, & 
             varid_zf = 37, &
             varid_dz = 37, &
             varid_det = 44, &
             varshape_Tb, varshape_Tp, varshape_zf, varshape_dz, varshape_det, &
             Nlat, Nlong, Ntime
  real(dp), dimension(:, :, :), allocatable :: Tb, Tp, zf, dz, det  
  type(Structure_group) :: Var

 ! Get basic information about the different imput files: 
  CALL GetVariableInfo(dir_Tb, varid_Tb, varname_Tb) 
  CALL GetVariableInfo(dir_Tp, varid_Tp, varname_Tp) 
  CALL GetVariableInfo(dir_zf, varid_zf, varname_zf) 
  CALL GetVariableInfo(dir_dz, varid_dz, varname_dz) 
  CALL GetVariableInfo(dir_det, varid_det, varname_det) 

  ! Get the dimension for the input variable: (Same for all the imput files)
  CALL griddims(dir_Tb, Nlat, Nlong, Ntime, Var)
  print *, varname_Tb
  print *, "lat  =", Nlat
  print *, "long =", Nlong
  
  ! Get the input grid file: 
  CALL readgrid(dir_Tb, varid_Tb, Nlat, Nlong, Ntime, Tb)
  CALL readgrid(dir_Tp, varid_Tp, Nlat, Nlong, Ntime, Tp)
  CALL readgrid(dir_zf, varid_zf, Nlat, Nlong, Ntime, zf)
  CALL readgrid(dir_dz, varid_dz, Nlat, Nlong, Ntime, dz)
  CALL readgrid(dir_det, varid_det, Nlat, Nlong, Ntime, det)
  

  ! Close the netCDF files : ----------------------------------------------------------------
  ierr = nf90_close(ncid_Tb)
  ierr = nf90_close(ncid_Tp)
  ierr = nf90_close(ncid_zf)
  ierr = nf90_close(ncid_dz)
  ierr = nf90_close(ncid_det)  

end program OpenNetCDFFiles
