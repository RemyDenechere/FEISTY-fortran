program Run_physiology
    use Parameters
    use Physiology
    use Structure 
    use Derivative
    use GetNetCDFInf
    use OMP_LIB

    implicit none 
    
    type(Structure_group) :: Var
    type(Save_structure2D) :: Data
    type(Save_structure1D) :: Data_MNTH
    type(ini_fish_data) :: Data_F_ini
    integer :: Ntime, Nspace
    real(dp), dimension(:, :), allocatable :: DataTp, DataTb, Datadz, &
                                              Datadet, DataZM
    integer :: ispace, count, itime, iDAY, iYR, imonth
    real(dp) :: T1, T2, T3
    logical :: Spinup = .false.

    CALL cpu_time(T1)

    ! Initialisation: ----------------------------------------------------------
    CALL Initialisation(Spinup, Var, Nspace, Ntime, Data_F_ini, Data, DataTp, DataTb, Datadz, Datadet, DataZM)
    CALL cpu_time(T2)

    print *, "------------------------------"
    print *, "     Simulation parameters    "
    print *, '# Days              ', Ntime
    print *, '# month             ', Nmonth
    print *, '# Year              ', Ntime/365
    print *, '# Spacial grid      ', Nspace
    print *, "Initialisation time " , T2-T1, "sec"
    print *, "Start simulation, takes ~ 30min"
    print *, "------------------------------"

    Nspace = 1    

    ! Loops over space and time: ---------------------------------
    Do ispace = 1, Nspace
        CALL initPhysiology(Spinup, ispace, Data_F_ini, Var)    ! Give initial conditions for the system 
        itime = 0                                               ! Restart days counter
        count = 0                                               ! Restart month counter
        Do iYr = 1, YR ! Loop Year
            Do imonth = 1, 12 ! Loop Month
                CALL init_store_MNTH(Data_MNTH, MNTH(imonth))                   ! Define size vector to store daily data in a month 
                Do iDAY = 1, MNTH(imonth) ! Loop Days
                    itime = itime + 1                                           ! Counts the days to get input
                    CALL Get_Environental_data2D(Var, DataTp, DataTb, &         ! Get the environemntal data for
                                 Datadz, Datadet, DataZM, ispace, itime)        ! that specific day
                    CALL CalcBiomass(Var)                                       ! Calcul biomass at day+1
                    stop          
                    CALL store_MNTH(Data_MNTH, Var, iDAY)                       ! Store the monthly data 
                end Do ! End Loop Days
                count = count + 1                                               ! Counts the month to save data
                CALL store_data2D(Data, Data_MNTH, ispace, count, MNTH(imonth)) ! Calcul and store the monthly average
            end Do ! End Loop Month
        end Do ! End Loop Year
    end Do
    
    CALL save_data(Spinup, Data, Nspace)  ! Save Netcdf 



    CALL cpu_time(T3)
    print *, "Simulation done !"
    print *, "Running time",  (T3-T2)/60, "min"
    print *, "Total time  ",  (T3-T1)/60, "min"
 

end program Run_physiology