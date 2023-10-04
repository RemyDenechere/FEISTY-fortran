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
    real(dp), dimension(:), allocatable :: IniSf, IniSp, IniSd, IniMf, & 
                                           IniMp, IniMd, IniLp, IniLd
    integer :: ispace, count = 0, itime = 0, iDAY, iYR, imonth
    real(dp) :: T1, T2, T3
    logical :: Spinup = .true.
    integer, dimension(12) :: MNTH

    CALL cpu_time(T1)
        
    ! Initialisation: ----------------------------------------------------------
    CALL Initialisation(Spinup, Var, Nspace, Ntime, Data_F_ini, Data, DataTp, DataTb, Datadz, Datadet, DataZM, MNTH)
    CALL cpu_time(T2)

    print *, '# Days         ', Ntime
    print *, '# Spacial grid ', Nspace
    print *, "Initialisation time", T2-T1, "sec"
    print *, "Start simulation, takes ~ 30min"



    ! Loops over space and time: ---------------------------------
    Do ispace = 1, Nspace
        CALL initPhysiologySpinup(Var)
        Do iYr = 1, YR
            Do imonth = 1, 12
                CALL init_store_MNTH(Data_MNTH, MNTH(imonth))
                Do iDAY = 1, MNTH(imonth)
                    itime = itime + 1
                    CALL Get_Environental_data2D(Var, DataTp, DataTb, Datadz, Datadet, DataZM, ispace, itime)
                    CALL CalcBiomass(Var)
                    CALL store_MNTH(Data_MNTH, Var, iDAY)
                end Do
                count = count+1
                CALL store_data2D(Data, Data_MNTH, ispace, count, MNTH(imonth))
            end Do 
        end Do
    end Do

    CALL save_data(Spinup, Data_F_ini, Data, Nspace, Ntime)

    CALL cpu_time(T3)
    print *, "Simulation done !"
    print *, "Running time",  (T3-T2)/60, "min"
    print *, "Total time  ",  (T3-T1)/60, "min"
 

end program Run_physiology