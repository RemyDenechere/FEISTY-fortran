module Structure 
    use Parameters
    
    implicit none 

    type :: Structure_Fish
    !------------------------------------
    ! Structure type for all the physiological 
    ! functions 
    !------------------------------------------------------------------------------------
        real(dp) :: B                   ! Biomass
        real(dp) :: w                   ! weight
        real(dp) :: Tcorr_e = 0         ! temperature correction for Encounter and Cmax
        real(dp) :: Tcorr_met = 0       ! temperature correction for metabolism
        real(dp) :: V = 0               ! Encounter rate 
        real(dp) :: f = 0               ! Total feeding level
        real(dp) :: cmax = 0            ! Maximum consumption rate 
        real(dp) :: cons_Mz = 0         ! Consumption of MesoZooplankton              
        real(dp) :: cons_Fish = 0       ! Consumption of fish
        real(dp) :: cons = 0            ! Total consumption rate
        real(dp) :: met = 0             ! metabolic cost 
        real(dp) :: mu_p = 0            ! Predation mortality 
        real(dp) :: mu_f = 0            ! Fishing mortality 
        real(dp) :: mu_a = 0            ! Natural mortality 
        real(dp) :: mu = 0              ! Total mortality
        real(dp) :: E_A = 0             ! Available energy 
        real(dp) :: Fout = 0            ! flux out of a size class 
        real(dp) :: Repro = 0           ! Reproduction flux 
        ! real(dp) :: Rec = 0             ! Recruitment 
  
        ! Feeding level for each prey : ------------------------------------------------
        real(dp) :: f_Zm = 0            
        real(dp) :: f_Sf = 0            ! --
        real(dp) :: f_Sp = 0            ! --
        real(dp) :: f_Sd = 0            ! --
        real(dp) :: f_Mf = 0            ! --
        real(dp) :: f_Mp = 0            ! --
        real(dp) :: f_Md = 0            ! --
        real(dp) :: f_Lp = 0            ! --
        real(dp) :: f_Ld = 0            ! --
        real(dp) :: f_BE = 0
         ! consumption for each prey : ------------------------------------------------
        real(dp) :: cons_Zm = 0            
        real(dp) :: cons_Sf = 0            ! --
        real(dp) :: cons_Sp = 0            ! --
        real(dp) :: cons_Sd = 0            ! --
        real(dp) :: cons_Mf = 0            ! --
        real(dp) :: cons_Mp = 0            ! --
        real(dp) :: cons_Md = 0            ! --
        real(dp) :: cons_Lp = 0            ! --
        real(dp) :: cons_Ld = 0            ! --
        real(dp) :: cons_BE = 0            ! --

    end type Structure_Fish

    type :: Structure_Resource 
        real(dp) :: B          ! Biomass 
    end type Structure_Resource
    
    type :: Structure_group
        type(Structure_Resource) :: Mz, BE
        type(Structure_Fish) :: Sf, Sp, Sd, &
                                Mf, Mp, Md, & 
                                Lp, Ld

        ! Global variable ()
        real(dp) :: zf = 0                   ! Fraction of zooplankton mortality loss consumed  
        real(dp) :: Tp = 0                   ! Pelagic temperature
        real(dp) :: Tb = 0                   ! Benthic temperature
        real(dp) :: dz = 0                   ! Biomass consumed by top predators 
        real(dp) :: det = 0                  ! Detritus flux to benthic community
        real(dp), dimension(nDeriv) :: dudt  ! variable containing the derivative 
        
        real(dp) :: Nlat
        real(dp) :: Nlong
        real(dp) :: Ntime
        real(dp) :: Nspace
    end type Structure_group
    
    type :: Save_structure3D
        real(dp), dimension(:, :, :), allocatable :: Sf, Sp, Sd, Mf, Mp, Md, Lp, Ld
    end type

    type :: Save_structure2D
        real(dp), dimension(:, :), allocatable :: Sf, Sp, Sd, Mf, Mp, Md, Lp, Ld, BE
    end type

    type :: Save_structure1D
    real(dp), dimension(:), allocatable :: Sf, Sp, Sd, Mf, Mp, Md, Lp, Ld, BE
    end type

    type :: ini_fish_data
        real(dp), dimension(:), allocatable :: IniSf, IniSp, IniSd, IniMf, IniMp, IniMd , IniLp, IniLd, IniBE
    end type 

    contains 

    ! Define initial condition for a grid cell
    subroutine initPhysiology(Spinup, ispace, Data_F_ini, this)
        logical, intent(in) :: Spinup
        integer, intent(in) :: ispace
        type(Structure_group), intent(inout) :: this
        type(ini_fish_data)  , intent(inout) :: Data_F_ini
    
        if (Spinup) then 
            ! this%Mz%B = 0.001
            this%BE%B = 0.001
            this%Sf%B = 0.001
            this%Sp%B = 0.001
            this%Sd%B = 0.001
            this%Mf%B = 0.001
            this%Mp%B = 0.001
            this%Md%B = 0.001
            this%Lp%B = 0.001
            this%Ld%B = 0.001
        else 
            ! this%Mz%B = Data_F_ini%Mz(ispace)
            this%BE%B = Data_F_ini%iniBE(ispace)
            this%Sf%B = Data_F_ini%iniSf(ispace)
            this%Sp%B = Data_F_ini%iniSp(ispace)
            this%Sd%B = Data_F_ini%iniSd(ispace)
            this%Mf%B = Data_F_ini%iniMf(ispace)
            this%Mp%B = Data_F_ini%iniMp(ispace)
            this%Md%B = Data_F_ini%iniMd(ispace)
            this%Lp%B = Data_F_ini%iniLp(ispace)
            this%Ld%B = Data_F_ini%iniLd(ispace)

        end if 
        
        ! Move this 
        ! Individual Mass (g) geometric mean for each group 
        this%Sf%w = 10.0**((log10(0.001)+log10(0.5))/2)
        this%Sp%w = 10.0**((log10(0.001)+log10(0.5))/2)
        this%Sd%w = 10.0**((log10(0.001)+log10(0.5))/2)
        this%Mf%w = 10.0**((log10(0.5)+log10(250.0))/2) 
        this%Mp%w = 10.0**((log10(0.5)+log10(250.0))/2) 
        this%Md%w = 10.0**((log10(0.5)+log10(250.0))/2) 
        this%Lp%w = 10.0**((log10(250.0)+log10(125000.0))/2)
        this%Ld%w = 10.0**((log10(250.0)+log10(125000.0))/2)

    end subroutine initPhysiology
    
    subroutine init_save_data3D(this, Nlat, Nlong)
        type(Save_structure3D) :: this
        integer :: Nlat, Nlong
        allocate(this%Sf(Nlat, Nlong, Nmonth))
        allocate(this%Sp(Nlat, Nlong, Nmonth))
        allocate(this%Sd(Nlat, Nlong, Nmonth))
        allocate(this%Mf(Nlat, Nlong, Nmonth))
        allocate(this%Mp(Nlat, Nlong, Nmonth))
        allocate(this%Md(Nlat, Nlong, Nmonth))
        allocate(this%Lp(Nlat, Nlong, Nmonth))
        allocate(this%Ld(Nlat, Nlong, Nmonth))
    end subroutine init_save_data3D

    subroutine init_save_data2D(this, Nspace)
        type(Save_structure2D) :: this
        integer, intent(in) :: Nspace
        allocate(this%BE(Nspace, Nmonth))
        allocate(this%Sf(Nspace, Nmonth))
        allocate(this%Sp(Nspace, Nmonth))
        allocate(this%Sd(Nspace, Nmonth))
        allocate(this%Mf(Nspace, Nmonth))
        allocate(this%Mp(Nspace, Nmonth))
        allocate(this%Md(Nspace, Nmonth))
        allocate(this%Lp(Nspace, Nmonth))
        allocate(this%Ld(Nspace, Nmonth))
    end subroutine init_save_data2D

    subroutine init_store_MNTH(this, Ndays)
        type(Save_structure1D) :: this
        integer, intent(in) :: Ndays
        allocate(this%BE(Ndays))
        allocate(this%Sf(Ndays))
        allocate(this%Sp(Ndays))
        allocate(this%Sd(Ndays))
        allocate(this%Mf(Ndays))
        allocate(this%Mp(Ndays))
        allocate(this%Md(Ndays))
        allocate(this%Lp(Ndays))
        allocate(this%Ld(Ndays))
    end subroutine init_store_MNTH

    subroutine store_MNTH(this, that, iDAY)
        type(Save_structure1D) :: this
        type(Structure_group) :: that
        integer, intent(in) :: iDAY
        this%BE(iDAY) = that%BE%B
        this%Sf(iDAY) = that%Sf%B
        this%Sp(iDAY) = that%Sp%B
        this%Sd(iDAY) = that%Sd%B
        this%Mf(iDAY) = that%Mf%B
        this%Mp(iDAY) = that%Mp%B
        this%Md(iDAY) = that%Md%B
        this%Lp(iDAY) = that%Lp%B
        this%Ld(iDAY) = that%Ld%B
    end subroutine store_MNTH

    subroutine store_data2D(this, that, ispace, imonth, Ndays)
        type(Save_structure2D) :: this
        type(Save_structure1D) :: that
        integer, intent(in) :: ispace, imonth, Ndays

        this%BE(ispace, imonth) = sum(that%BE)/Ndays
        this%Sf(ispace, imonth) = sum(that%Sf)/Ndays
        this%Sp(ispace, imonth) = sum(that%Sp)/Ndays
        this%Sd(ispace, imonth) = sum(that%Sd)/Ndays
        this%Mf(ispace, imonth) = sum(that%Mf)/Ndays
        this%Mp(ispace, imonth) = sum(that%Mp)/Ndays
        this%Md(ispace, imonth) = sum(that%Md)/Ndays
        this%Lp(ispace, imonth) = sum(that%Lp)/Ndays
        this%Ld(ispace, imonth) = sum(that%Ld)/Ndays

        deallocate(that%BE)
        deallocate(that%Sf)
        deallocate(that%Sp)
        deallocate(that%Sd)
        deallocate(that%Mf)
        deallocate(that%Mp)
        deallocate(that%Md)
        deallocate(that%Lp)
        deallocate(that%Ld)
    end subroutine store_data2D

    



end module Structure