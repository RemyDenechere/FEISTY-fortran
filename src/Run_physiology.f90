program Run_physiology
    use Parameters
    use Physiology
    use Structure 
    use GetNetCDFInf
    use OMP_LIB
 
    implicit none
    
    ! Variables ----------------------------------------------------------
    integer :: itime, iDAY, iYR, Year, ilayer, ilath, ilongh
    real(dp) :: T1, T2, T3, sim_time

    call init_parameters ! Initialisation of the parameters

    print *, "-------------------------------------"
    print *, " Simulation of FEISTY offline using COBALT 1D "
    print *, " at ", trim(loc), ", Spinup: ", Spinup_logical
    print *, "-------------------------------------"
    
    ! Initialisation: ----------------------------------------------------------
    CALL cpu_time(T1)
    CALL Init_FEISTY()
    CALL cpu_time(T2)
 
    ! Increasing the spinup time! 
    if (Spinup_logical) then 
        Year = FEISTY%Ntime/366
        sim_time = 1.73
    else 
        Year = FEISTY%Ntime/366
        sim_time = 1.73/200.0 
    end if 

    print *, "-------------------------------------"
    print *, "     Simulation parameters    "
    print *, '# Days              ', FEISTY%Ntime
    print *, '# month             ', Year *12
    print *, '# Year              ', Year
    print *, '# Layer             ', FEISTY%Nlayer
    print *, '# Latitude          ', FEISTY%Nlath
    print *, '# Longitude         ', FEISTY%Nlongh
    print *, "Initialisation time " , T2-T1, "sec"
    print *, "Start simulation, takes ~", sim_time, "min"
    print *, "-------------------------------------"

    ! Loops over latitude,  longitude, year and day  ----------------------------------------------------------
    Do ilath = 1, FEISTY%Nlath; Do ilongh = 1, FEISTY%Nlongh; Do iYr = 1, Year; Do iDAY = 1, 366 
            FEISTY%itime = (iYr -1) * 366 + iDAY ! time of simulation used for saving data if spinup
            FEISTY%iDay = iDay
            FEISTY%ilath = ilath
            FEISTY%ilongh = ilongh
            CALL init_Biomass ! Initialisation of the biomass
            CALL Get_Environmental_data ! Get the environmental data and integrate them over depth
            CALL Calc_FEISTY_Deriv                                        ! Calcul biomass at day+1
            CALL store_daily_biomass    ! Save the daily biomass
            CALL store_daily_diag       ! Save the daily diagnostic
        enddo; enddo ! End Loop Year and day
    enddo ; enddo; ! } longh; lat; layer

    print *, "-------------------------------------"
    print *, "     starting write_output_netcdf    "
    CALL write_output_netcdf  ! Save Netcdf 

    CALL cpu_time(T3)
    print *, "-------------------------------------"
    print *, "Simulation done !"
    print *, "Running time",  (T3-T2)/60, "min"
    print *, "Total time  ",  (T3-T1)/60, "min"
    print *, "-------------------------------------"
    

end program Run_physiology

   
