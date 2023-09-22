program Run_physiology
    use Parameters
    use Physiology
    use Structure 
    use Derivative
    use GetNetCDFInf

    implicit none 
    
    type(Structure_group) :: Var
    type(Save_structure) :: Data
    integer :: Nlat=0, Nlong=0, Ntime=0
    real(dp), dimension(:, :, :), allocatable :: DataTp, DataTb, &
                                                 Datadz, Datadet, &
                                                 DataZM
    integer :: ilat, ilong, itime
    real    :: T1, T2, T3

    call cpu_time(T1)
                                                 
    ! Initialisation: ----------------------------------------------------------
    CALL griddims(dir_Tb, Nlat, Nlong, Ntime, var)
    CALL ini_input(DataTp, DataTb, Datadz, Datadet, DataZM)
    CALL init_save_data_3D(Data, Nlat, Nlong, Ntime)

    call cpu_time(T2)
    print *, "Initialisation time", T2-T1, "sec"
    print *, "Start simulation, takes ~ 47min"

    Nlat = 1
    ! Nlong = 1
    ! Loops over latitude, longitude and time: ---------------------------------
    Do ilat = 1, Nlat
        print*, "lat =  ", ilat
        CALL initPhysiology(Var)
        DO ilong = 1, Nlong
            print*, "lat =  ", ilat
            CALL initPhysiology(Var)
            Do itime = 1, Ntime
                CALL Get_Environental_data(Var, DataTp, DataTb, Datadz, Datadet, DataZM, ilat, ilong, itime)
                CALL CalcBiomass(var)
                CALL save_data(Data, var, ilat, ilong, itime)
            END DO
        END DO 
    END DO


    ! Write each variable to a separate NetCDF file : ---------------------------
    call write_nc_file('output/Sf_bio_Spinup.nc', 'Sf', Data%Sf, Nlat, Nlong, Ntime)
    call write_nc_file('output/Sp_bio_Spinup.nc', 'Sp', Data%Sp, Nlat, Nlong, Ntime)
    call write_nc_file('output/Sd_bio_Spinup.nc', 'Sd', Data%Sd, Nlat, Nlong, Ntime)
    call write_nc_file('output/Mf_bio_Spinup.nc', 'Mf', Data%Mf, Nlat, Nlong, Ntime)
    call write_nc_file('output/Mp_bio_Spinup.nc', 'Mp', Data%Mp, Nlat, Nlong, Ntime)
    call write_nc_file('output/Md_bio_Spinup.nc', 'Md', Data%Md, Nlat, Nlong, Ntime)
    call write_nc_file('output/Lp_bio_Spinup.nc', 'Lp', Data%Lp, Nlat, Nlong, Ntime)
    call write_nc_file('output/Ld_bio_Spinup.nc', 'Ld', Data%Ld, Nlat, Nlong, Ntime)

    call cpu_time(T3)
    print *, "Simulation done !"
    print *, "Running time",  (T3-T2)/60, "min"

    

    ! Running time: 
    ! ----------------------------------------------------
    ! test physioloical calc
    ! ----------------------------------------------------
    ! print*, "Sf Biomass Zoo        ", Var%Mz%B
    ! print*, "Sf Tcorr_e            ", Var%Sf%Tcorr_e
    ! print*, "Sf Tcorr_met          ", Var%Sf%Tcorr_met
    ! print*, "Md Tcorr_e            ", Var%Md%Tcorr_e
    ! print*, "Md Tcorr_met          ", Var%Md%Tcorr_met
    ! print*, "Sf Clearance rate Sf  ", Var%Sf%V
    ! print*, "Sf Cmax Sf            ", Var%Sf%cmax
    ! print*, "Sf feeding level Sf   ", Var%Sf%f
    ! print*, "Sf Total consumption  ", Var%Sf%cons 
    ! print*, "Sf consumption Mz     ", Var%Sf%cons_Mz 
    ! print*, "Sf Total mort         ", Var%Sf%mu
    ! print*, "Sf Met loss           ", Var%Sf%met
    ! print*, "Sf Available energy   ", Var%Sf%E_A
    ! print*, "Sf Fout               ", Var%Sf%Fout 
    ! print*, "Sf Repro flux         ", Var%Sf%Repro 
    ! print*, "BE biomass            ", Var%BE%B
    ! print*, "Frac Zoo lost         ", Var%zf
    ! print*, "Large Dem Cons        ", Var%Ld%cons

    ! ----------------------------------------------------
    ! Test Biomass all group
    ! ----------------------------------------------------
    ! print*, "----------------------------------"
    ! print*, "lat =  ", ilat
    ! print*, "long = ", ilong
    ! print*, "----------------------------------"
    ! print*, "Biomass Sf   ", Var%Sf%B
    ! print*, "Biomass Sp   ", Var%Sp%B
    ! print*, "Biomass Sd   ", Var%Sd%B
    ! print*, "Biomass Mf   ", Var%Mf%B
    ! print*, "Biomass Mp   ", Var%Mp%B
    ! print*, "Biomass Md   ", Var%Md%B
    ! print*, "Biomass Lp   ", Var%Lp%B
    ! print*, "Biomass Ld   ", Var%Ld%B
    

end program Run_physiology