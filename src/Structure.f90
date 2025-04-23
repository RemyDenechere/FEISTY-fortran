module Structure 
    use Parameters
    
    implicit none 


    !-----------------------------------------------------------------------
    ! Structure type representing one fish group (i.e., one functional group
    ! one size).
    !------------------------------------------------------------------------------------
    type, public :: Fish
        real(dp) :: B                   ! Biomass
        real(dp) :: w                   ! weight
        real(dp) :: Texp                ! Temperature experienced by the fish
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

    end type Fish


    !-----------------------------------------------------------------------
    ! Structure type representing one Benthic group (can be extended if needed).
    !------------------------------------------------------------------------------------
    type :: Benthos 
        real(dp) :: B   ! Biomass 
    end type Benthos


    !-----------------------------------------------------------------------
    ! Structure type representing one MesoZooplankton (can be extended if needed).
    !------------------------------------------------------------------------------------
    type, public :: MesoZooplankton 
        real(dp) :: B             = 0.0 , &  ! Biomass 
                    dz            = 0.0 , &  ! Mortality by High trophic Level mortality
                    Zcons_VS_dZ   = 0.0      ! MesoZooplankton consumption from FEISTY over dZm estmated from COBALT
    end type MesoZooplankton


    !-----------------------------------------------------------------------
    ! Structure type Containing all the variable that are use for each time step calculation
    !------------------------------------------------------------------------------------
    type, public :: FEISTY_type
        type(MesoZooplankton)   , dimension(2) :: mesozoo
        type(Benthos)           , dimension(1) :: benthos
        type(Fish)              , dimension(8) :: fish
        
        ! Global variable ()
        real(dp) :: Tp = 0                   ! Pelagic temperature
        real(dp) :: Tb = 0                   ! Benthic temperature
        real(dp) :: det = 0                  ! Detritus flux to benthic community
        real(dp), dimension(nDeriv) :: dBdt  ! variable containing the derivative
        real(dp), dimension(nFishGroup) :: tpel
        real(dp) :: Sd_Fout_B_int = 0
        real(dp) :: Ld_Repro_end = 0
        real(dp) :: Md_Fout_end = 0

        integer :: Nlath
        integer :: Nlongh
        integer :: Ntime
        integer :: Nlayer

        integer :: ilath
        integer :: ilongh
        integer :: itime
        integer :: iDay

        real(dp), dimension(75) :: zt                   ! Depth of each layer
        real(dp), dimension(75) :: layer_thickness      ! Thickness of each layer
        real(dp), dimension(75) :: layer_mid            ! Mid depth of each layer
        real(dp), dimension(9, 9) :: lat                ! Latitude
        real(dp), dimension(9, 9) :: lon                ! Longitude
        real(dp), dimension(4, 4) :: max_depth          ! Sea floor depth
        integer, allocatable :: idx_100m(:)  ! Index of the 100m depth
    end type FEISTY_type


    !-----------------------------------------------------------------------
    ! Fish Diagnostic variable
    !------------------------------------------------------------------------------------
    type, public :: Diag_fish 
        real(dp), dimension(:, :, :), allocatable :: & 
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
    end type Diag_fish

    
    !-----------------------------------------------------------------------
    ! MesoZooplankton Diagnostic variable
    !------------------------------------------------------------------------------------
    type :: Diag_mesozoo
        real(dp), dimension(:,:,:), allocatable :: Zcon_VS_dZ
    end type Diag_mesozoo


    !-----------------------------------------------------------------------
    ! All Diagnostic variable use in FEISTY module
    !------------------------------------------------------------------------------------
    type :: FEISTY_diag
        type(Diag_fish), dimension(nFishGroup) :: fish

        ! Zooplankton oversonsumption
        type(Diag_mesozoo), dimension(nMesoZoo) :: mesozoo
    end type FEISTY_diag
    

    !-----------------------------------------------------------------------
    ! All tracers use in FEISTY module
    !------------------------------------------------------------------------------------
    type :: FEISTY_tracers
        real(dp), dimension(:, :, :), allocatable :: Bio
    end type FEISTY_tracers

    type :: Initial_conditions
        real(dp), dimension(:, :), allocatable :: IniBio
    end type 

    ! ====================================================================================!
    ! Public variables and structures
    ! =========================================================================!
    type(FEISTY_type),          public                                      :: FEISTY
    type(FEISTY_diag),          public                                      :: diags
    type(FEISTY_tracers),       public, dimension(nDeriv)                   :: tracers
    type(Initial_conditions),   public, dimension(nDeriv)                   :: IC_tracers_Bio
    real(dp),                   public, dimension(:, :, :, :), allocatable  :: DataTemp, DataZM,&
                                                                               Datadzm, DataZL, Datadzl
    real(dp),                   public, dimension(:, :, :)   , allocatable  :: Datadet

    contains 

    ! Define initial condition for a grid cell
    subroutine initPhysiology()
        integer :: i
    
        if (Spinup_logical) then
            ! Fish: 
            do i = 1, nFishGroup
                FEISTY%fish(i)%B = IC
            end do
            
            ! Benthic: 
            do i = 1, nBenthos  
                FEISTY%benthos(i)%B = IC
            end do
            
        else 
            ! Fish:
            do i = 1, nFishGroup
                FEISTY%fish(i)%B = IC_tracers_Bio(i)%IniBio(FEISTY%ilath, FEISTY%ilongh)
            end do
            ! Benthic: 
            do i = 1, nBenthos  
                FEISTY%benthos(i)%B = IC_tracers_Bio(nFishGroup + i)%IniBio(FEISTY%ilath, FEISTY%ilongh)
            end do
        end if 
    end subroutine initPhysiology

     ! Define initial condition for a grid cell
    subroutine init_Biomass
        integer :: i
    
        ! Gives initial condition for 1st time step if Spinup 
        if ((Spinup_logical) .and. (FEISTY%itime .eq. int(1))) then
            ! Fish: 
            do i = 1, nFishGroup
                FEISTY%fish(i)%B = IC
            end do
            ! Benthic: 
            do i = 1, nBenthos 
                FEISTY%benthos(i)%B = IC
            end do
        
        ! Gives initial condition for 1st time step from spinup 
        elseif ((Spinup_logical .eqv. .false.) .and. (FEISTY%itime .eq. int(1))) then
            do i = 1, nFishGroup
                FEISTY%fish(i)%B = IC_tracers_Bio(i)%IniBio(FEISTY%ilath, FEISTY%ilongh)
            end do
        
        ! Gives biomass from previous time step for any time 
        elseif (FEISTY%itime .gt. int(1)) then 
            ! Allocate fish biomass 
            do i = 1, nFishGroup
                FEISTY%fish(i)%B = tracers(i)%Bio(FEISTY%itime-1, FEISTY%ilath, FEISTY%ilongh)
            end do 
            ! allocate Benthic biomass: 
            do i = 1, nBenthos  
                FEISTY%benthos(i)%B = tracers(i + nFishGroup)%Bio(FEISTY%itime-1, FEISTY%ilath, FEISTY%ilongh)
            end do
        end if 
    end subroutine init_Biomass
    

    subroutine allocate_tracers()
        integer :: i
        do i = 1, nDeriv
            allocate(tracers(i)%Bio(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))
        end do
    end subroutine allocate_tracers

    subroutine allocate_diags()
        integer :: i
    
        do i = 1, nFishGroup
            allocate(diags%fish(i)%f(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))       ; diags%fish(i)%f = 0.0
            allocate(diags%fish(i)%cmax(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%cmax = 0.0
            allocate(diags%fish(i)%cons(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%cons = 0.0
            allocate(diags%fish(i)%met(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))     ; diags%fish(i)%met = 0.0
            allocate(diags%fish(i)%mu_p(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%mu_p = 0.0
            allocate(diags%fish(i)%mu_f(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%mu_f = 0.0
            allocate(diags%fish(i)%mu_a(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%mu_a = 0.0
            allocate(diags%fish(i)%mu(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))      ; diags%fish(i)%mu = 0.0
            allocate(diags%fish(i)%E_A(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))     ; diags%fish(i)%E_A = 0.0
            allocate(diags%fish(i)%Fout(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%Fout = 0.0
            allocate(diags%fish(i)%Repro(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))   ; diags%fish(i)%Repro = 0.0
    
            ! Feeding level for each prey
            allocate(diags%fish(i)%f_Zm(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%f_Zm = 0.0
            allocate(diags%fish(i)%f_Zl(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%f_Zl = 0.0
            allocate(diags%fish(i)%f_Sf(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%f_Sf = 0.0
            allocate(diags%fish(i)%f_Sp(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%f_Sp = 0.0
            allocate(diags%fish(i)%f_Sd(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%f_Sd = 0.0
            allocate(diags%fish(i)%f_Mf(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%f_Mf = 0.0
            allocate(diags%fish(i)%f_Mp(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%f_Mp = 0.0
            allocate(diags%fish(i)%f_Md(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%f_Md = 0.0
            allocate(diags%fish(i)%f_Lp(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%f_Lp = 0.0
            allocate(diags%fish(i)%f_Ld(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%f_Ld = 0.0
            allocate(diags%fish(i)%f_BE(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))    ; diags%fish(i)%f_BE = 0.0
        end do
    
        ! Zooplankton overconsumption
        do i = 1, nMesoZoo
            allocate(diags%mesozoo(i)%Zcon_VS_dZ(FEISTY%Ntime, FEISTY%Nlath, FEISTY%Nlongh))
        end do
    end subroutine allocate_diags

    subroutine store_daily_biomass()
        integer :: i

        ! Store the daily biomass of each group (FEISTY tracers)
        do i = 1, nFishGroup
            tracers(i)%Bio(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh) = FEISTY%fish(i)%B
        end do 
        do i = 1, nBenthos 
            tracers(i+nFishGroup)%Bio(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh) = FEISTY%benthos(i)%B
        end do 
    end subroutine store_daily_biomass

    subroutine store_daily_diag()
        integer :: i

        Do i = 1, nFishGroup
            diags%fish(i)%f(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)     =  FEISTY%fish(i)%f          ! Total feeding level
            diags%fish(i)%cmax(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%cmax           ! Maximum consumption rate 
            diags%fish(i)%cons(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%cons          ! Total consumption rate
            diags%fish(i)%met(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)   =  FEISTY%fish(i)%met           ! metabolic cost 
            diags%fish(i)%mu_p(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%mu_p          ! Predation mortality 
            diags%fish(i)%mu_f(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%mu_f          ! Fishing mortality 
            diags%fish(i)%mu_a(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%mu_a          ! Natural mortality 
            diags%fish(i)%mu(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)    =  FEISTY%fish(i)%mu          ! Total mortality
            diags%fish(i)%E_A(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)   =  FEISTY%fish(i)%E_A          ! Available energy 
            diags%fish(i)%Fout(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%Fout          ! flux out of a size class 
            diags%fish(i)%Repro(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh) =  FEISTY%fish(i)%Repro         ! Reproduction flux 
    
            ! Feeding level for each prey : ------------------------------------------------
            diags%fish(i)%f_Zm(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%f_Zm         
            diags%fish(i)%f_Zl(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%f_Zl         ! --         
            diags%fish(i)%f_Sf(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%f_Sf         ! --
            diags%fish(i)%f_Sp(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%f_Sp         ! --
            diags%fish(i)%f_Sd(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%f_Sd         ! --
            diags%fish(i)%f_Mf(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%f_Mf         ! --
            diags%fish(i)%f_Mp(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%f_Mp         ! --
            diags%fish(i)%f_Md(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%f_Md        ! --
            diags%fish(i)%f_Lp(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%f_Lp        ! --
            diags%fish(i)%f_Ld(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%f_Ld         ! --
            diags%fish(i)%f_BE(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh)  =  FEISTY%fish(i)%f_BE  
        end Do 
        
        ! Zooplankton oversonsumption
        do i = 1, nMesoZoo
            diags%mesozoo(i)%Zcon_VS_dZ(FEISTY%itime, FEISTY%ilath, FEISTY%ilongh) =  FEISTY%mesozoo(i)%Zcons_VS_dZ 
        end do
    end subroutine store_daily_diag

    subroutine Print_FEISTY_diagnostic()
        integer :: i

        print *, " ------------------- FEISTY outputs --------------------- "
        print *, "lath " , FEISTY%ilath
        print *, "longh",  FEISTY%ilongh
        print *, "time " , FEISTY%itime
        
        print *, " "
        print *, " ------------------- FEISTY inputs --------------------- "
        print *, "Temperature  Pelagic    " , FEISTY%Tp                  ! Pelagic temperature
        print *, "Temperature  Benthic    " , FEISTY%Tb                  ! Benthic temperature
        print *, "Medium MesoZoo B        " , FEISTY%mesozoo(Mz)%B       ! Fraction of zooplankton mortality loss consumed
        print *, "Large MesoZoo B         " , FEISTY%mesozoo(Lz)%B       ! Fraction of zooplankton mortality loss consumed  
        print *, "mort Medium MesoZoo B   " , FEISTY%mesozoo(Mz)%dz      ! Biomass of medium zooplankton consumed by top predators 
        print *, "mort Large MesoZoo B    " , FEISTY%mesozoo(Lz)%dz      ! Biomass of Large zooplankton consumed by top predators 
        print *, "Detritus fluxto sea bed " , FEISTY%det                 ! Detritus flux to benthic community
        
        print *,  " "
        print *, " ------------------- Biomass at t + 1  --------------------- "
        do i = 1, nFishGroup
            print *, "bio ", trim(tracers_name(i)), "= ", FEISTY%fish(i)%B
        end do
        print *, "bio BE= ", FEISTY%benthos(1)%B

        print *,  " "
        print *, " ------------------- all derivatives  --------------------- "
        do i = 1, nFishGroup
            print *, "d", trim(tracers_name(i)), "/dt = ", FEISTY%dBdt(i)
        end do 

        print *,  " "
        print *, " ------------------- all diagnostics  --------------------- "
        Do i = 1, nFishGroup
            print *, trim(tracers_name(i)), ' diagnostics:'
            print *, "Physiology"
            print *, "tpel: ", FEISTY%tpel(i)          ! Biomass
            print *, "Texp: ",  FEISTY%fish(i)%Texp     ! temperature experienced by fish
            print *, "Tcorr_e: ", FEISTY%fish(i)%Tcorr_e  ! temperature correction for encounter and cmax 
            print *, "Tcorr_met: ", FEISTY%fish(i)%Tcorr_met ! temperature correction for metabolism
            print *, 'f: ', FEISTY%fish(i)%f          ! Total feeding level
            print *, 'cmax: ', FEISTY%fish(i)%cmax           ! Maximum consumption rate 
            print *, 'cmax_w: ', FEISTY%fish(i)%cmax /  FEISTY%fish(i)%Tcorr_e        ! Maximum consumption rate 
            print *, 'v:      ', FEISTY%fish(i)%V          ! Encounter rate
            print *, 'v_w:    ', FEISTY%fish(i)%V / FEISTY%fish(i)%Tcorr_e         ! Encounter rate
            print *, 'cons: ', FEISTY%fish(i)%cons          ! Total consumption rate
            print *, 'met: ',FEISTY%fish(i)%met           ! metabolic cost 
            print *, 'mu_p: ', FEISTY%fish(i)%mu_p          ! Predation mortality 
            print *, 'mu_f: ', FEISTY%fish(i)%mu_f          ! Fishing mortality 
            print *, 'mu_a: ', FEISTY%fish(i)%mu_a          ! Natural mortality 
            print *, 'mu: ', FEISTY%fish(i)%mu          ! Total mortality
            print *, 'E_A: ', FEISTY%fish(i)%E_A          ! Available energy 
            print *, 'Fout: ', FEISTY%fish(i)%Fout          ! flux out of a size class 
            print *, 'Repro: ', FEISTY%fish(i)%Repro         ! Reproduction flux 

            print *,   "----------------------------------- "
            print *, "Feeding level for each prey : "
            print *, 'f_Zm: ', FEISTY%fish(i)%cons_Zm / FEISTY%fish(i)%cmax      
            print *, 'f_Zl: ', FEISTY%fish(i)%cons_Zl / FEISTY%fish(i)%cmax         ! --         
            print *, 'f_Sf: ', FEISTY%fish(i)%cons_Sf / FEISTY%fish(i)%cmax         ! --
            print *, 'f_Sp: ', FEISTY%fish(i)%cons_Sp / FEISTY%fish(i)%cmax         ! --
            print *, 'f_Sd: ', FEISTY%fish(i)%cons_Sd / FEISTY%fish(i)%cmax         ! --
            print *, 'f_Mf: ', FEISTY%fish(i)%cons_Mf / FEISTY%fish(i)%cmax         ! --
            print *, 'f_Mp: ', FEISTY%fish(i)%cons_Mp / FEISTY%fish(i)%cmax         ! --
            print *, 'f_Md: ', FEISTY%fish(i)%cons_Md / FEISTY%fish(i)%cmax       ! --
            print *, 'f_Lp: ', FEISTY%fish(i)%cons_Lp / FEISTY%fish(i)%cmax        ! --
            print *, 'f_Ld: ', FEISTY%fish(i)%cons_Ld / FEISTY%fish(i)%cmax         ! --
            print *, 'f_BE: ', FEISTY%fish(i)%cons_BE / FEISTY%fish(i)%cmax 

            print *,   "----------------------------------- "
            print *, "Encounter for each prey : "
            print *, 'Enc_Zm: ', FEISTY%fish(i)%f_Zm / ((1-FEISTY%fish(i)%f_Zm) * FEISTY%fish(i)%cmax)      
            print *, 'Enc_Zl: ', FEISTY%fish(i)%f_Zl / ((1-FEISTY%fish(i)%f_Zl) * FEISTY%fish(i)%cmax)         ! --         
            print *, 'Enc_Sf: ', FEISTY%fish(i)%f_Sf / ((1-FEISTY%fish(i)%f_Sf) * FEISTY%fish(i)%cmax)         ! --
            print *, 'Enc_Sp: ', FEISTY%fish(i)%f_Sp / ((1-FEISTY%fish(i)%f_Sp) * FEISTY%fish(i)%cmax)         ! --
            print *, 'Enc_Sd: ', FEISTY%fish(i)%f_Sd / ((1-FEISTY%fish(i)%f_Sd) * FEISTY%fish(i)%cmax)         ! --
            print *, 'Enc_Mf: ', FEISTY%fish(i)%f_Mf / ((1-FEISTY%fish(i)%f_Mf) * FEISTY%fish(i)%cmax)         ! --
            print *, 'Enc_Mp: ', FEISTY%fish(i)%f_Mp / ((1-FEISTY%fish(i)%f_Mp) * FEISTY%fish(i)%cmax)         ! --
            print *, 'Enc_Md: ', FEISTY%fish(i)%f_Md / ((1-FEISTY%fish(i)%f_Md) * FEISTY%fish(i)%cmax)         ! --
            print *, 'Enc_Lp: ', FEISTY%fish(i)%f_Lp / ((1-FEISTY%fish(i)%f_Lp) * FEISTY%fish(i)%cmax)         ! --
            print *, 'Enc_Ld: ', FEISTY%fish(i)%f_Ld / ((1-FEISTY%fish(i)%f_Ld) * FEISTY%fish(i)%cmax)         ! --
            print *, 'Enc_BE: ', FEISTY%fish(i)%f_BE / ((1-FEISTY%fish(i)%f_BE) * FEISTY%fish(i)%cmax) 


            print *,   "----------------------------------- "
            print *, "Consumption for each prey : "
            print *, 'cons_Zm: ', FEISTY%fish(i)%cons_Zm         !
            print *, 'cons_Zl: ', FEISTY%fish(i)%cons_Zl         ! --         
            print *, 'cons_Sf: ', FEISTY%fish(i)%cons_Sf         ! --
            print *, 'cons_Sp: ', FEISTY%fish(i)%cons_Sp         ! --
            print *, 'cons_Sd: ', FEISTY%fish(i)%cons_Sd         ! --
            print *, 'cons_Mf: ', FEISTY%fish(i)%cons_Mf         ! --
            print *, 'cons_Mp: ', FEISTY%fish(i)%cons_Mp         ! --
            print *, 'cons_Md: ', FEISTY%fish(i)%cons_Md         ! --
            print *, 'cons_Lp: ', FEISTY%fish(i)%cons_Lp         ! --
            print *, 'cons_Ld: ', FEISTY%fish(i)%cons_Ld         ! --
            print *, 'cons_BE: ', FEISTY%fish(i)%cons_BE         ! --

            print *,  " "
        end Do 

        stop 
    end subroutine Print_FEISTY_diagnostic


end module Structure