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
        real(dp) :: cons_Mz = 0         ! Consumption of MesoZooplankton medium
        real(dp) :: cons_Lz = 0         ! Consumption of MesoZooplankton medium              
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
        real(dp) :: f_Zl = 0            ! --         
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
        real(dp) :: cons_Zl = 0            ! --         
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
        type(Structure_Resource) :: Mz, Lz, BE
        type(Structure_Fish) :: Sf, Sp, Sd, &
                                Mf, Mp, Md, & 
                                Lp, Ld

        ! Global variable ()
        real(dp) :: zfm = 0                  ! Fraction of zooplankton mortality loss consumed
        real(dp) :: zfl = 0                  ! Fraction of zooplankton mortality loss consumed  
        real(dp) :: Temp = 0                   ! Pelagic temperature
        real(dp) :: dzm = 0                  ! Biomass of medium zooplankton consumed by top predators 
        real(dp) :: dzl = 0                  ! Biomass of Large zooplankton consumed by top predators 
        real(dp) :: det = 0                  ! Detritus flux to benthic community
        real(dp), dimension(nDeriv) :: dudt  ! variable containing the derivative 
        real(dp) :: Zcons_VS_dZm = 0         ! Zm consumption from FEISTY over dZm estmated
        real(dp) :: Zcons_VS_dZl = 0         ! Zm consumption from FEISTY over dZl estmated
        real(dp) :: tpel_Ld = 0              ! Time in pelagic of large demersal depending on depth and abundance of resource
        real(dp) :: Sd_Fout_int = 0
        real(dp) :: Ld_Repro_end = 0

        real(dp) :: Nlath
        real(dp) :: Nlongh
        real(dp) :: Ntime
        real(dp) :: Nlayer

        real(dp) :: ilath
        real(dp) :: ilongh
        real(dp) :: itime
        real(dp) :: ilayer
    end type Structure_group

    type :: Structure_diag 
        real(dp), dimension(:, :, :, :), allocatable :: & 
        ! Physiology: -----------------------------------------------------------------
        f,&               ! Total feeding level
        cmax,&            ! Maximum consumption rate 
        cons,&            ! Total consumption rate
        met,&             ! metabolic cost 
        mu_p,&            ! Predation mortality 
        mu_f,&            ! Fishing mortality 
        mu_a,&            ! Natural mortality 
        mu,&              ! Total mortality
        E_A,&             ! Available energy 
        Fout,&            ! flux out of a size class 
        Repro,&           ! Reproduction flux 

        ! Feeding level for each prey : ------------------------------------------------
        f_Zm,&            
        f_Zl,&            ! --         
        f_Sf,&            ! --
        f_Sp,&            ! --
        f_Sd,&            ! --
        f_Mf,&            ! --
        f_Mp,&            ! --
        f_Md,&            ! --
        f_Lp,&            ! --
        f_Ld,&            ! --
        f_BE
    end type Structure_diag
    
    type :: Save_structure4D
        real(dp), dimension(:, :, :, :), allocatable :: Sf, Sp, Sd, Mf, Mp, Md, Lp, Ld, BE, Zcons_VS_dZm, Zcons_VS_dZl
        real(dp), dimension(:), allocatable :: Sd_Fout
    end type


    type :: Save_structure1D
        real(dp), dimension(:), allocatable :: Sf, Sp, Sd, Mf, Mp, Md, Lp, Ld, BE, Zcons_VS_dZm, Zcons_VS_dZl
    end type

    type :: ini_fish_data
        real(dp), dimension(:, :, :), allocatable :: IniSf, IniSp, IniSd, IniMf, IniMp, IniMd , IniLp, IniLd, IniBE
    end type 

    contains 

    ! Define initial condition for a grid cell
    subroutine initPhysiology(Spinup, ilayer, ilath, ilongh, Data_F_ini, this)
        logical, intent(in) :: Spinup
        integer, intent(in) :: ilayer, ilath, ilongh
        type(Structure_group), intent(inout) :: this
        type(ini_fish_data)  , intent(inout) :: Data_F_ini
    
        if (Spinup) then
            this%BE%B = IC
            this%Sf%B = IC
            this%Sp%B = IC
            this%Sd%B = IC
            this%Mf%B = IC
            this%Mp%B = IC
            this%Md%B = IC
            this%Lp%B = IC
            this%Ld%B = IC
        else 
            this%BE%B = Data_F_ini%IniBE(ilayer, ilath, ilongh)
            this%Sf%B = Data_F_ini%IniSf(ilayer, ilath, ilongh)
            this%Sp%B = Data_F_ini%IniSp(ilayer, ilath, ilongh)
            this%Sd%B = Data_F_ini%IniSd(ilayer, ilath, ilongh)
            this%Mf%B = Data_F_ini%IniMf(ilayer, ilath, ilongh)
            this%Mp%B = Data_F_ini%IniMp(ilayer, ilath, ilongh)
            this%Md%B = Data_F_ini%IniMd(ilayer, ilath, ilongh)
            this%Lp%B = Data_F_ini%IniLp(ilayer, ilath, ilongh)
            this%Ld%B = Data_F_ini%IniLd(ilayer, ilath, ilongh)
        end if 

    end subroutine initPhysiology

     ! Define initial condition for a grid cell
    subroutine init_Biomass_Layer(Spinup, itime, ilayer, ilath, ilongh, Data_F_ini, this, Data)
        logical, intent(in) :: Spinup
        integer, intent(in) :: itime, ilayer, ilath, ilongh
        type(Structure_group) , intent(inout) :: this
        type(ini_fish_data)   , intent(in)    :: Data_F_ini
        type(Save_structure4D), intent(in)    :: Data
    
        ! Gives initial condition for 1st time step if Spinup 
        if ((Spinup) .and. (itime .eq. int(1))) then
            this%BE%B = IC
            this%Sf%B = IC
            this%Sp%B = IC
            this%Sd%B = IC
            this%Mf%B = IC
            this%Mp%B = IC
            this%Md%B = IC
            this%Lp%B = IC
            this%Ld%B = IC
        
        ! Gives initial condition for 1st time step from spinup 
        elseif ((Spinup .eqv. .false.) .and. (itime .eq. int(1))) then 
            this%BE%B = Data_F_ini%IniBE(ilayer, ilath, ilongh)
            this%Sf%B = Data_F_ini%IniSf(ilayer, ilath, ilongh)
            this%Sp%B = Data_F_ini%IniSp(ilayer, ilath, ilongh)
            this%Sd%B = Data_F_ini%IniSd(ilayer, ilath, ilongh)
            this%Mf%B = Data_F_ini%IniMf(ilayer, ilath, ilongh)
            this%Mp%B = Data_F_ini%IniMp(ilayer, ilath, ilongh)
            this%Md%B = Data_F_ini%IniMd(ilayer, ilath, ilongh)
            this%Lp%B = Data_F_ini%IniLp(ilayer, ilath, ilongh)
            this%Ld%B = Data_F_ini%IniLd(ilayer, ilath, ilongh)
        
        ! Gives uses biomass from previous time step for any time 
        elseif (itime .gt. int(1)) then 
            this%BE%B = Data%BE(itime-1, ilayer, ilath, ilongh)
            this%Sf%B = Data%Sf(itime-1, ilayer, ilath, ilongh)
            this%Sp%B = Data%Sp(itime-1, ilayer, ilath, ilongh)
            this%Sd%B = Data%Sd(itime-1, ilayer, ilath, ilongh)
            this%Mf%B = Data%Mf(itime-1, ilayer, ilath, ilongh)
            this%Mp%B = Data%Mp(itime-1, ilayer, ilath, ilongh)
            this%Md%B = Data%Md(itime-1, ilayer, ilath, ilongh)
            this%Lp%B = Data%Lp(itime-1, ilayer, ilath, ilongh)
            this%Ld%B = Data%Ld(itime-1, ilayer, ilath, ilongh)
        
        ! ! Set up benthic biomass to 0.0 if not in the bottom layer: 
        ! elseif (ilayer .lt. this%Nlayer) then 
        !     this%BE%B = 0.0
        end if 

    end subroutine init_Biomass_Layer
    

    subroutine init_save_data4D(this, Ntime, Nlayer, Nlath, Nlongh)
        type(Save_structure4D) :: this
        integer :: Ntime, Nlayer, Nlath, Nlongh

        allocate(this%Sf(Ntime, Nlayer, Nlath, Nlongh))
        allocate(this%Sp(Ntime, Nlayer, Nlath, Nlongh))
        allocate(this%Sd(Ntime, Nlayer, Nlath, Nlongh))
        allocate(this%Mf(Ntime, Nlayer, Nlath, Nlongh))
        allocate(this%Mp(Ntime, Nlayer, Nlath, Nlongh))
        allocate(this%Md(Ntime, Nlayer, Nlath, Nlongh))
        allocate(this%Lp(Ntime, Nlayer, Nlath, Nlongh))
        allocate(this%Ld(Ntime, Nlayer, Nlath, Nlongh))
        allocate(this%BE(Ntime, Nlayer, Nlath, Nlongh))
        allocate(this%Zcons_VS_dZm(Ntime, Nlayer, Nlath, Nlongh))
        allocate(this%Zcons_VS_dZl(Ntime, Nlayer, Nlath, Nlongh))

        allocate(this%Sd_Fout(Nlayer))

    end subroutine init_save_data4D

    subroutine allocate_fish_diag(fish_diag, Ntime, Nlayer, Nlath, Nlongh)
        type(Structure_diag), dimension(nFishGroup) :: fish_diag
        integer, intent(in) :: Ntime, Nlayer, Nlath, Nlongh
        integer :: i

        Do i = 1, nFishGroup
            allocate(fish_diag(i)%f(Ntime, Nlayer, Nlath, Nlongh))       ; fish_diag(i)%f = 0.0          ! Total feeding level
            allocate(fish_diag(i)%cmax(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%cmax = 0.0           ! Maximum consumption rate 
            allocate(fish_diag(i)%cons(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%cons = 0.0          ! Total consumption rate
            allocate(fish_diag(i)%met(Ntime, Nlayer, Nlath, Nlongh))     ; fish_diag(i)%met = 0.0           ! metabolic cost 
            allocate(fish_diag(i)%mu_p(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%mu_p = 0.0          ! Predation mortality 
            allocate(fish_diag(i)%mu_f(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%mu_f = 0.0          ! Fishing mortality 
            allocate(fish_diag(i)%mu_a(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%mu_a = 0.0          ! Natural mortality 
            allocate(fish_diag(i)%mu(Ntime, Nlayer, Nlath, Nlongh))      ; fish_diag(i)%mu = 0.0          ! Total mortality
            allocate(fish_diag(i)%E_A(Ntime, Nlayer, Nlath, Nlongh))     ; fish_diag(i)%E_A = 0.0          ! Available energy 
            allocate(fish_diag(i)%Fout(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%Fout = 0.0          ! flux out of a size class 
            allocate(fish_diag(i)%Repro(Ntime, Nlayer, Nlath, Nlongh))   ; fish_diag(i)%Repro = 0.0         ! Reproduction flux 
    
            ! Feeding level for each prey : ------------------------------------------------
            allocate(fish_diag(i)%f_Zm(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%f_Zm = 0.0         
            allocate(fish_diag(i)%f_Zl(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%f_Zl = 0.0         ! --         
            allocate(fish_diag(i)%f_Sf(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%f_Sf = 0.0         ! --
            allocate(fish_diag(i)%f_Sp(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%f_Sp = 0.0         ! --
            allocate(fish_diag(i)%f_Sd(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%f_Sd = 0.0         ! --
            allocate(fish_diag(i)%f_Mf(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%f_Mf = 0.0         ! --
            allocate(fish_diag(i)%f_Mp(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%f_Mp = 0.0         ! --
            allocate(fish_diag(i)%f_Md(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%f_Md = 0.0        ! --
            allocate(fish_diag(i)%f_Lp(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%f_Lp = 0.0        ! --
            allocate(fish_diag(i)%f_Ld(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%f_Ld = 0.0         ! --
            allocate(fish_diag(i)%f_BE(Ntime, Nlayer, Nlath, Nlongh))    ; fish_diag(i)%f_BE = 0.0 
        end Do 
    end subroutine allocate_fish_diag

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
        allocate(this%Zcons_VS_dZm(Ndays))
        allocate(this%Zcons_VS_dZl(Ndays))
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
        this%Zcons_VS_dZm(iDay) = that%Zcons_VS_dZm
        this%Zcons_VS_dZl(iDay) = that%Zcons_VS_dZl
    end subroutine store_MNTH

    subroutine store_data_MNT(this, that, imonth, ilayer, ilath, ilongh, Ndays)
        type(Save_structure4D) :: this         ! Storage (Space, month)
        type(Save_structure1D) :: that         ! Daily data for the month 
        integer, intent(in) :: imonth, ilayer, ilath, ilongh, Ndays

        ! Store the average biomass of each group for the month
        this%BE(imonth, ilayer, ilath, ilongh) = sum(that%BE)/Ndays
        this%Sf(imonth, ilayer, ilath, ilongh) = sum(that%Sf)/Ndays
        this%Sp(imonth, ilayer, ilath, ilongh) = sum(that%Sp)/Ndays
        this%Sd(imonth, ilayer, ilath, ilongh) = sum(that%Sd)/Ndays
        this%Mf(imonth, ilayer, ilath, ilongh) = sum(that%Mf)/Ndays
        this%Mp(imonth, ilayer, ilath, ilongh) = sum(that%Mp)/Ndays
        this%Md(imonth, ilayer, ilath, ilongh) = sum(that%Md)/Ndays
        this%Lp(imonth, ilayer, ilath, ilongh) = sum(that%Lp)/Ndays
        this%Ld(imonth, ilayer, ilath, ilongh) = sum(that%Ld)/Ndays
        this%Zcons_VS_dZm(imonth, ilayer, ilath, ilongh) = sum(that%Zcons_VS_dZm)/Ndays
        this%Zcons_VS_dZl(imonth, ilayer, ilath, ilongh) = sum(that%Zcons_VS_dZl)/Ndays

        ! Deallocating the vectors to store next month daily values: 
        deallocate(that%BE)
        deallocate(that%Sf)
        deallocate(that%Sp)
        deallocate(that%Sd)
        deallocate(that%Mf)
        deallocate(that%Mp)
        deallocate(that%Md)
        deallocate(that%Lp)
        deallocate(that%Ld)
        deallocate(that%Zcons_VS_dZm)
        deallocate(that%Zcons_VS_dZl)
    end subroutine store_data_MNT

    subroutine store_daily_biomass(this, that, itime, ilayer, ilath, ilongh)
        type(Save_structure4D) :: this         ! Storage (Space, month)
        type(Structure_group) :: that         ! Daily data for the month 
        integer, intent(in) :: itime, ilayer, ilath, ilongh

        ! Store the average biomass of each group for the month
        this%BE(itime, ilayer, ilath, ilongh) = that%BE%B
        this%Sf(itime, ilayer, ilath, ilongh) = that%Sf%B
        this%Sp(itime, ilayer, ilath, ilongh) = that%Sp%B
        this%Sd(itime, ilayer, ilath, ilongh) = that%Sd%B
        this%Mf(itime, ilayer, ilath, ilongh) = that%Mf%B
        this%Mp(itime, ilayer, ilath, ilongh) = that%Mp%B
        this%Md(itime, ilayer, ilath, ilongh) = that%Md%B
        this%Lp(itime, ilayer, ilath, ilongh) = that%Lp%B
        this%Ld(itime, ilayer, ilath, ilongh) = that%Ld%B
        this%Zcons_VS_dZm(itime, ilayer, ilath, ilongh) = that%Zcons_VS_dZm
        this%Zcons_VS_dZl(itime, ilayer, ilath, ilongh) = that%Zcons_VS_dZl
            
        this%Sd_Fout(ilayer) = that%Sd%Fout
    end subroutine store_daily_biomass

    subroutine store_daily_diag(fish_diag, Var, itime, ilayer, ilath, ilongh)
        type(Structure_diag), dimension(nFishGroup) :: fish_diag
        type(Structure_group) :: Var         ! Daily data
        integer, intent(in) :: itime, ilayer, ilath, ilongh
        integer :: i

        Do i = 1, nFishGroup
            fish_diag(i)%f(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%cmax(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%cons(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%met(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%mu_p(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%mu_f(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%mu_a(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%mu(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%E_A(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%Fout(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%Repro(itime, ilayer, ilath, ilongh)   = 0.0
    
            ! Feeding level for each prey : ------------------------------------------------
            fish_diag(i)%f_Zm(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%f_Zl(itime, ilayer, ilath, ilongh)      = 0.0
            fish_diag(i)%f_Sf(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%f_Sp(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%f_Sd(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%f_Mf(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%f_Mp(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%f_Md(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%f_Lp(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%f_Ld(itime, ilayer, ilath, ilongh)   = 0.0
            fish_diag(i)%f_BE(itime, ilayer, ilath, ilongh)   = 0.0
        end Do 

    end subroutine store_daily_diag

    subroutine Calc_trans_layer(this, that, itime, ilayer, ilath, ilongh)
        type(Save_structure4D) :: this         ! Storage (time layer, space)
        type(Structure_group) :: that          ! Daily data for the month 
        integer, intent(in) :: itime, ilayer, ilath, ilongh

        that%Sd_Fout_int = sum(this%Sd_Fout)
        that%Ld_Repro_end = that%Ld%Repro

    end subroutine Calc_trans_layer


end module Structure