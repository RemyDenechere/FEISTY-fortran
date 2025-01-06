program Generate_IC_FEISTY_2D
    use Parameters
    use Structure 
    use GetNetCDFInf

    implicit none

    type(FEISTY_type)    :: FEISTY
    type(FEISTY_diag)    :: diags
    type(FEISTY_tracers)    , dimension(nDeriv)     :: tracers
    type(Initial_conditions), dimension(nDeriv)     :: IC_tracers_Bio
    real(dp), dimension(:, :, :, :), allocatable    :: DataTemp, Datadet, &
                                                        DataZM, Datadzm, DataZL, Datadzl
    real(dp), dimension(9, 9)                       :: Datalat, Datalon
    real(dp), dimension(4, 4)                       :: Datamax_depth
    real(dp), dimension(75)                         :: Datazt
    integer :: Ntime, Nlayer, Nlath, Nlongh
    integer :: itime, iDAY, iYR, Year, ilayer, ilath, ilongh
    real(dp) :: T1, T2, T3, sim_time
    logical :: Spinup = .true.  

    CALL Init_FEISTY(Spinup, FEISTY, diags, IC_tracers_Bio, tracers, &
                     Ntime, Nlayer, Nlath, Nlongh, &
                     DataTemp, Datadet, Datadzm, DataZM, Datadzl, DataZL, &
                     Datazt, Datalat, Datalon, Datamax_depth)

    CALL FEISTY_Save_2D_tracers(Spinup, tracers, Ntime, Nlayer, Nlath, Nlongh, FEISTY%lat, FEISTY%lon, FEISTY%zt)



end program Generate_IC_FEISTY_2D