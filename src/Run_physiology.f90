program Run_physiology
    use Parameters
    use Physiology
    use Structure 
    use GetNetCDFInf
    use OMP_LIB
 
    implicit none
    
    ! Variables ----------------------------------------------------------
    type(FEISTY_type)    :: FEISTY
    type(FEISTY_diag)    :: diags
    type(FEISTY_tracers)    , dimension(nDeriv)     :: tracers
    type(Initial_conditions), dimension(nDeriv)     :: IC_tracers_Bio
    real(dp), dimension(:, :, :, :), allocatable    :: DataTemp, Datadet, &
                                                       DataZM, Datadzm, DataZL, Datadzl
    integer :: itime, iDAY, iYR, Year, ilayer, ilath, ilongh
    real(dp) :: T1, T2, T3, sim_time
    logical :: Spinup = .true.

    print *, "-------------------------------------"
    print *, " Simulation of FEISTY offline using COBALT 1D "
    print *, " at ", trim(loc), ", Spinup: ", Spinup
    print *, "-------------------------------------"
    
    ! Initialisation: ----------------------------------------------------------
    CALL cpu_time(T1)
    CALL Init_FEISTY(Spinup, FEISTY, diags, IC_tracers_Bio, tracers, &
                     DataTemp, Datadet, Datadzm, DataZM, Datadzl, DataZL)
    CALL cpu_time(T2)
 
    ! Increasing the spinup time! 
    if (Spinup) then 
        Year = Ntime/366
        sim_time = 1.73
    else 
        Year = Ntime/366
        sim_time = 1.73/200.0 
    end if 

    print *, "-------------------------------------"
    print *, "     Simulation parameters    "
    print *, '# Days              ', Ntime
    print *, '# month             ', Year *12
    print *, '# Year              ', Year
    print *, '# Layer             ', Nlayer
    print *, '# Latitude          ', Nlath
    print *, '# Longitude         ', Nlongh
    print *, "Initialisation time " , T2-T1, "sec"
    print *, "Start simulation, takes ~", sim_time, "min"
    print *, "-------------------------------------"

    ! Loops over latitude,  longitude, year and day  ----------------------------------------------------------
    Do ilath = 1, Nlath; Do ilongh = 1, Nlongh; Do iYr = 1, Year; Do iDAY = 1, 366 
            itime = (iYr -1) * 366 + iDAY 
            CALL init_Biomass(Spinup, itime, ilath, ilongh, IC_tracers_Bio, FEISTY, tracers) ! Initialisation of the biomass
            CALL Get_Environental_data(FEISTY, DataTemp(ilath, ilongh, :, itime), Datadet(ilath, ilongh, :, itime), &
                                               Datadzm(ilath, ilongh, :, itime), DataZM(ilath, ilongh, :, itime), &
                                               Datadzl(ilath, ilongh, :, itime), DataZL(ilath, ilongh, :, itime), &
                                               iDAY, ilath, ilongh) ! Get the environmental data and integrate them over depth                                                                                 
            CALL Calc_FEISTY_Deriv(FEISTY)                                        ! Calcul biomass at day+1
            CALL store_daily_biomass(FEISTY, tracers, itime, ilath, ilongh)  ! Save the daily biomass
            CALL store_daily_diag(diags, FEISTY, itime, ilath, ilongh)       ! Save the daily diagnostic
        enddo; enddo ! End Loop Year and day
    enddo ; enddo; ! } longh; lat; layer

    CALL write_output_netcdf(Spinup, tracers, diags, Ntime, Nlayer, Nlath, Nlongh, FEISTY%lat, FEISTY%lon, FEISTY%zt)  ! Save Netcdf 


    CALL cpu_time(T3)
    print *, "-------------------------------------"
    print *, "Simulation done !"
    print *, "Running time",  (T3-T2)/60, "min"
    print *, "Total time  ",  (T3-T1)/60, "min"
    print *, "-------------------------------------"
    

end program Run_physiology

   
