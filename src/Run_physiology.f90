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
    type(Structure_diag), dimension(nFishGroup) :: fish_diag
    type(ini_fish_data) :: Data_F_ini
    integer :: Ntime, Nlayer, Nlath, Nlongh
    real(dp), dimension(:, :, :, :), allocatable :: DataTemp, Datadet, &
                                                    DataZM, Datadzm, DataZL, Datadzl
    integer :: itime, iDAY, iYR, Year, ilayer, ilath, ilongh
    real(dp) :: T1, T2, T3, sim_time
    logical :: Spinup = .true. ! .false. !   

    ! Initialisation: ----------------------------------------------------------
    CALL cpu_time(T1)
    CALL Initialisation(Spinup, Var, Ntime, Nlayer, Nlath, Nlongh, Data_F_ini, Data, &
                        DataTemp, Datadet, Datadzm, DataZM, Datadzl, DataZL, fish_diag)
    CALL cpu_time(T2)
 
    ! Increasing the spinup time! 
    if (Spinup) then 
        Year = Ntime/365
        sim_time = 1.6546143499999999
    else 
        Year = Ntime/365
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
    Do ilath = 1, Nlath; Do ilongh = 1, Nlongh
        ! Loops over time ----------------------------------------------------------
        Do iYr = 1, Year; Do iDAY = 1, 365 ! Loop Year and Day
            itime = (iYr -1) * 365 + iDay 
            Do ilayer = 1, Nlayer; 
                CALL init_Biomass_Layer(Spinup, itime, ilayer, ilath, ilongh, Data_F_ini, var, Data)
                CALL Get_Environental_data(Var, DataTemp, Datadet, &
                                           Datadzm, DataZM, Datadzl, DataZL, &
                                           iDAY, ilayer, ilath, ilongh)                                                                                  
                CALL CalcBiomass(Var)                                           ! Calcul biomass at day+1
                CALL store_daily_biomass(Data, Var, itime, ilayer, ilath, ilongh)  ! Calcul and store the monthly average
                CALL store_daily_diag(fish_diag, Var, itime, ilayer, ilath, ilongh)
            enddo
            call Calc_trans_layer(Data, Var, itime, ilayer, ilath, ilongh)
        enddo; enddo ! End Loop Year and day
    enddo ; enddo; ! } longh; lat; layer

    CALL save_data(Spinup, Data, fish_diag, Ntime, Nlayer, Nlath, Nlongh)  ! Save Netcdf 


    print*, "    Check Benthic biomass after simulation     "
    print*, " Dim data to save: ", SIZE(Data%BE, 1), SIZE(Data%BE, 2), SIZE(Data%BE, 3), SIZE(Data%BE, 4)
    print*, " 1st  layer: ", Data%BE((Ntime-5):Ntime, 1 , 1, 1)
    print*, " 68th layer: ", Data%BE((Ntime-5):Ntime, 68, 1, 1)
    print*, " lst  layer: ", Data%BE((Ntime-5):Ntime, 75, 1, 1)

    CALL cpu_time(T3)
    print *, "-------------------------------------"
    print *, "Simulation done !"
    print *, "Running time",  (T3-T2)/60, "min"
    print *, "Total time  ",  (T3-T1)/60, "min"
    print *, "-------------------------------------"
    

end program Run_physiology

   
