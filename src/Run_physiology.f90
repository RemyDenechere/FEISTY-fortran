program Run_physiology
    use Parameters
    use Physiology
    use Structure 
    use Derivative
    use GetNetCDFInf
    use OMP_LIB
 
    implicit none
    
    type(Structure_group) :: Var
    type(Save_structure4D) :: Data
    type(Save_structure1D) :: Data_MNTH
    type(ini_fish_data) :: Data_F_ini
    integer :: Ntime, Nlayer, Nlath, Nlongh
    real(dp), dimension(:, :, :, :), allocatable :: DataTemp, Datadet, &
                                                    DataZM, Datadzm, DataZL, Datadzl
    integer :: ispace, Count_MNT, itime, iDAY, iYR, imonth, Year, Stop_count, ilayer, ilath, ilongh
    real(dp) :: T1, T2, T3, sim_time
    logical :: Spinup = .false. ! .true. ! 

    ! Initialisation: ----------------------------------------------------------
    CALL cpu_time(T1)
    CALL Initialisation(Spinup, Var, Ntime, Nlayer, Nlath, Nlongh, Data_F_ini, Data, &
                        DataTemp, Datadet, Datadzm, DataZM, Datadzl, DataZL)
    CALL cpu_time(T2)
 
    ! Increasing the spinup time! 
    if (Spinup) then 
        Year = Ntime / 365
        sim_time = 1.6546143499999999
    else 
        Year = Ntime /365
        sim_time = 1.6546143499999999/200.0 
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

    ! Loops over layers, latitude and longitude ----------------------------------------------------------
    Do ilayer = 1, Nlayer; Do ilath = 1, Nlath; Do ilongh = 1, Nlongh
        CALL initPhysiology(Spinup, ilayer, ilath, ilongh, Data_F_ini, Var)    ! Give initial conditions for the system 

        ! Loops over time ----------------------------------------------------------
        Do iYr = 1, Year; Do iDAY = 1, 365                                       ! Loop Days  
                CALL Get_Environental_data(Var, DataTemp, Datadet, &
                            Datadzm, DataZM, Datadzl, DataZL, &
                            iDAY, ilayer, ilath, ilongh)                                                                                  
                CALL CalcBiomass(Var)                                       ! Calcul biomass at day+1
                CALL store_daily_data(Data, Var, iDAY, ilayer, ilath, ilongh)        ! Calcul and store the monthly average
        end do; end do ! End Loop Year and day
    enddo ; enddo; enddo ! } longh; lat; layer

    CALL save_data(Spinup, Data, Ntime, Nlayer, Nlath, Nlongh)  ! Save Netcdf 

    CALL cpu_time(T3)
    print *, "-------------------------------------"
    print *, "Simulation done !"
    print *, "Running time",  (T3-T2)/60, "min"
    print *, "Total time  ",  (T3-T1)/60, "min"
    print *, "-------------------------------------"

end program Run_physiology

   
