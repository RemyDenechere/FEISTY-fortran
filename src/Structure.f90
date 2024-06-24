module Structure 
    use Parameters
    
    implicit none 


    !-----------------------------------------------------------------------
    ! Structure type representing one fish group (i.e., one functional group
    ! one size).
    !------------------------------------------------------------------------------------
    type :: Fish
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
    type :: MesoZooplankton 
        real(dp) :: B             = 0.0 , &  ! Biomass 
                    Zcons_VS_dZ   = 0.0      ! MesoZooplankton consumption from FEISTY over dZm estmated from COBALT
    end type MesoZooplankton


    !-----------------------------------------------------------------------
    ! Structure type Containing all the variable that are use for each time step calculation
    !------------------------------------------------------------------------------------
    type :: FEISTY_type
        type(MesoZooplankton)   , dimension(2) :: mesozoo
        type(Benthos)           , dimension(1) :: benthos
        type(Fish)              , dimension(8) :: fish
        
        ! Global variable ()
        real(dp) :: zfm = 0                  ! Fraction of zooplankton mortality loss consumed
        real(dp) :: zfl = 0                  ! Fraction of zooplankton mortality loss consumed  
        real(dp) :: Temp = 0                 ! Pelagic temperature
        real(dp) :: dzm = 0                  ! Biomass of medium zooplankton consumed by top predators 
        real(dp) :: dzl = 0                  ! Biomass of Large zooplankton consumed by top predators 
        real(dp) :: det = 0                  ! Detritus flux to benthic community
        real(dp), dimension(nDeriv) :: dBdt  ! variable containing the derivative
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
    end type FEISTY_type


    !-----------------------------------------------------------------------
    ! Fish Diagnostic variable
    !------------------------------------------------------------------------------------
    type :: Diag_fish 
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
    end type Diag_fish


    !-----------------------------------------------------------------------
    ! MesoZooplankton Diagnostic variable
    !------------------------------------------------------------------------------------
    type :: Diag_mesozoo
        real(dp), dimension(:,:,:,:), allocatable :: Zcon_VS_dZ
    end type Diag_mesozoo


    !-----------------------------------------------------------------------
    ! All Diagnostic variable use in FEISTY module
    !------------------------------------------------------------------------------------
    type :: FEISTY_diag
        type(Diag_fish), dimension(nFishGroup) :: fish

        ! Zooplankton oversonsumption
        type(Diag_mesozoo), dimension(nMesoZoo) :: mesozoo

        ! Small Demersal growth to Medium dermersal
        real(dp), dimension(:), allocatable :: Sd_Fout
    end type FEISTY_diag
    

    !-----------------------------------------------------------------------
    ! All tracers use in FEISTY module
    !------------------------------------------------------------------------------------
    type :: FEISTY_tracers
        real(dp), dimension(:, :, :, :), allocatable :: Bio
    end type FEISTY_tracers


    type :: Save_structure1D
        real(dp), dimension(:), allocatable :: Sf, Sp, Sd, Mf, Mp, Md, Lp, Ld, BE, Zcons_VS_dZm, Zcons_VS_dZl
    end type

    type :: Initial_conditions
        real(dp), dimension(:, :, :), allocatable :: IniBio
        ! IniSf, IniSp, IniSd, IniMf, IniMp, IniMd , IniLp, IniLd, IniBE
    end type 

    contains 

    ! Define initial condition for a grid cell
    subroutine initPhysiology(Spinup, ilayer, ilath, ilongh, IC_fish_Bio, FEISTY)
        logical, intent(in) :: Spinup
        integer, intent(in) :: ilayer, ilath, ilongh
        type(FEISTY_type), intent(inout) :: FEISTY
        type(Initial_conditions), intent(inout), dimension(nDeriv) :: IC_fish_Bio
        integer :: i
    
        if (Spinup) then
            ! Fish: 
            do i = 1, nFishGroup
                FEISTY%fish(i)%B = IC
            end do
            
            ! Benthic: 
            do i = nFishGroup + 1, nDeriv 
                FEISTY%benthos(i)%B = IC
            end do
            
        else 
            ! Fish:
            do i = 1, nFishGroup
                FEISTY%fish(i)%B = IC_fish_Bio(i)%IniBio(ilayer, ilath, ilongh)
            end do
            ! Benthic: 
            do i = nFishGroup + 1, nDeriv 
                FEISTY%benthos(i)%B = IC_fish_Bio(i)%IniBio(ilayer, ilath, ilongh)
            end do
        end if 

    end subroutine initPhysiology

     ! Define initial condition for a grid cell
    subroutine init_Biomass_Layer(Spinup, itime, ilayer, ilath, ilongh, IC_fish_Bio, FEISTY, tracers)
        type(FEISTY_type)       , intent(inout)                    :: FEISTY
        type(Initial_conditions), intent(in)   , dimension(nDeriv) :: IC_fish_Bio
        type(FEISTY_tracers)    , intent(in)   , dimension(nDeriv) :: tracers
        logical, intent(in) :: Spinup
        integer, intent(in) :: itime, ilayer, ilath, ilongh
        integer :: i
    
        ! Gives initial condition for 1st time step if Spinup 
        if ((Spinup) .and. (itime .eq. int(1))) then
            ! Fish: 
            do i = 1, nFishGroup
                FEISTY%fish(i)%B = IC
            end do
            ! Benthic: 
            do i = nFishGroup + 1, nDeriv 
                FEISTY%benthos(i)%B = IC
            end do
        
        ! Gives initial condition for 1st time step from spinup 
        elseif ((Spinup .eqv. .false.) .and. (itime .eq. int(1))) then
            do i = 1, nFishGroup
                FEISTY%fish(i)%B = IC_fish_Bio(i)%IniBio(ilayer, ilath, ilongh)
            end do
        
        ! Gives uses biomass from previous time step for any time 
        elseif (itime .gt. int(1)) then 
            do i = 1, nFishGroup
                FEISTY%fish(i)%B = tracers(i)%Bio(itime-1, ilayer, ilath, ilongh)
            end do 
            ! Benthic: 
            do i = nFishGroup + 1, nDeriv 
                FEISTY%benthos(i)%B = tracers(i)%Bio(itime-1, ilayer, ilath, ilongh)
            end do
        end if 

    end subroutine init_Biomass_Layer
    

    subroutine allocate_tracers(tracers, Ntime, Nlayer, Nlath, Nlongh)
        type(FEISTY_tracers), dimension(nDeriv) :: tracers
        integer :: Ntime, Nlayer, Nlath, Nlongh
        integer :: i

        do i = 1, nDeriv
            allocate(tracers(i)%Bio(Ntime, Nlayer, Nlath, Nlongh))
        end do 

    end subroutine allocate_tracers

    subroutine allocate_diags(diags, Ntime, Nlayer, Nlath, Nlongh)
        type(FEISTY_diag) :: diags
        integer, intent(in) :: Ntime, Nlayer, Nlath, Nlongh
        integer :: i

        Do i = 1, nFishGroup
            allocate(diags%fish(i)%f(Ntime, Nlayer, Nlath, Nlongh))       ; diags%fish(i)%f = 0.0          ! Total feeding level
            allocate(diags%fish(i)%cmax(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%cmax = 0.0           ! Maximum consumption rate 
            allocate(diags%fish(i)%cons(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%cons = 0.0          ! Total consumption rate
            allocate(diags%fish(i)%met(Ntime, Nlayer, Nlath, Nlongh))     ; diags%fish(i)%met = 0.0           ! metabolic cost 
            allocate(diags%fish(i)%mu_p(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%mu_p = 0.0          ! Predation mortality 
            allocate(diags%fish(i)%mu_f(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%mu_f = 0.0          ! Fishing mortality 
            allocate(diags%fish(i)%mu_a(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%mu_a = 0.0          ! Natural mortality 
            allocate(diags%fish(i)%mu(Ntime, Nlayer, Nlath, Nlongh))      ; diags%fish(i)%mu = 0.0          ! Total mortality
            allocate(diags%fish(i)%E_A(Ntime, Nlayer, Nlath, Nlongh))     ; diags%fish(i)%E_A = 0.0          ! Available energy 
            allocate(diags%fish(i)%Fout(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%Fout = 0.0          ! flux out of a size class 
            allocate(diags%fish(i)%Repro(Ntime, Nlayer, Nlath, Nlongh))   ; diags%fish(i)%Repro = 0.0         ! Reproduction flux 
    
            ! Feeding level for each prey : ------------------------------------------------
            allocate(diags%fish(i)%f_Zm(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%f_Zm = 0.0         
            allocate(diags%fish(i)%f_Zl(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%f_Zl = 0.0         ! --         
            allocate(diags%fish(i)%f_Sf(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%f_Sf = 0.0         ! --
            allocate(diags%fish(i)%f_Sp(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%f_Sp = 0.0         ! --
            allocate(diags%fish(i)%f_Sd(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%f_Sd = 0.0         ! --
            allocate(diags%fish(i)%f_Mf(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%f_Mf = 0.0         ! --
            allocate(diags%fish(i)%f_Mp(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%f_Mp = 0.0         ! --
            allocate(diags%fish(i)%f_Md(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%f_Md = 0.0        ! --
            allocate(diags%fish(i)%f_Lp(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%f_Lp = 0.0        ! --
            allocate(diags%fish(i)%f_Ld(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%f_Ld = 0.0         ! --
            allocate(diags%fish(i)%f_BE(Ntime, Nlayer, Nlath, Nlongh))    ; diags%fish(i)%f_BE = 0.0  
        end Do 
        
        ! Zooplankton oversonsumption
        do i = 1, nMesoZoo
            allocate(diags%mesozoo(i)%Zcon_VS_dZ(Ntime, Nlayer, Nlath, Nlongh))
        end do
        ! Small Demersal growth to Medium dermersal
        allocate(diags%Sd_Fout(Nlayer))
    end subroutine allocate_diags

    subroutine store_daily_biomass(FEISTY, tracers, itime, ilayer, ilath, ilongh)
        type(FEISTY_tracers), intent(inout), dimension(nDeriv) :: tracers
        type(FEISTY_type)   , intent(inout)  :: FEISTY      ! Daily data for the month 
        integer, intent(in) :: itime, ilayer, ilath, ilongh
        integer :: i

        ! Store the daily biomass of each group (FEISTY tracers)
        do i = 1, nFishGroup
            tracers(i)%Bio(itime, ilayer, ilath, ilongh) = FEISTY%fish(i)%B
        end do 

        do i = nFishGroup + 1, nDeriv
            tracers(i)%Bio(itime, ilayer, ilath, ilongh) = FEISTY%benthos(i)%B
        end do 
    end subroutine store_daily_biomass

    subroutine store_daily_diag(diags, FEISTY, itime, ilayer, ilath, ilongh)
        type(FEISTY_diag)   , intent(inout)  :: diags
        type(FEISTY_type)   , intent(inout)  :: FEISTY      ! Daily data for the month 
        integer, intent(in) :: itime, ilayer, ilath, ilongh
        integer :: i

        Do i = 1, nFishGroup
            diags%fish(i)%f(itime, ilayer, ilath, ilongh)     =  FEISTY%fish(i)%f          ! Total feeding level
            diags%fish(i)%cmax(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%cmax           ! Maximum consumption rate 
            diags%fish(i)%cons(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%cons          ! Total consumption rate
            diags%fish(i)%met(itime, ilayer, ilath, ilongh)   =  FEISTY%fish(i)%met           ! metabolic cost 
            diags%fish(i)%mu_p(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%mu_p          ! Predation mortality 
            diags%fish(i)%mu_f(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%mu_f          ! Fishing mortality 
            diags%fish(i)%mu_a(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%mu_a          ! Natural mortality 
            diags%fish(i)%mu(itime, ilayer, ilath, ilongh)    =  FEISTY%fish(i)%mu          ! Total mortality
            diags%fish(i)%E_A(itime, ilayer, ilath, ilongh)   =  FEISTY%fish(i)%E_A          ! Available energy 
            diags%fish(i)%Fout(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%Fout          ! flux out of a size class 
            diags%fish(i)%Repro(itime, ilayer, ilath, ilongh) =  FEISTY%fish(i)%Repro         ! Reproduction flux 
    
            ! Feeding level for each prey : ------------------------------------------------
            diags%fish(i)%f_Zm(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%f_Zm         
            diags%fish(i)%f_Zl(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%f_Zl         ! --         
            diags%fish(i)%f_Sf(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%f_Sf         ! --
            diags%fish(i)%f_Sp(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%f_Sp         ! --
            diags%fish(i)%f_Sd(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%f_Sd         ! --
            diags%fish(i)%f_Mf(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%f_Mf         ! --
            diags%fish(i)%f_Mp(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%f_Mp         ! --
            diags%fish(i)%f_Md(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%f_Md        ! --
            diags%fish(i)%f_Lp(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%f_Lp        ! --
            diags%fish(i)%f_Ld(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%f_Ld         ! --
            diags%fish(i)%f_BE(itime, ilayer, ilath, ilongh)  =  FEISTY%fish(i)%f_BE  
        end Do 
        
        ! Zooplankton oversonsumption
        do i = 1, nMesoZoo
            diags%mesozoo(i)%Zcon_VS_dZ(itime, ilayer, ilath, ilongh) =  FEISTY%mesozoo(i)%Zcons_VS_dZ 
        end do

        ! Small Demersal growth to Medium dermersal 
        diags%Sd_Fout(ilayer) = FEISTY%fish(Sd)%Fout

    end subroutine store_daily_diag

    subroutine Calc_trans_layer(diags, FEISTY)
        type(FEISTY_diag), intent(in)     :: diags         ! Storage (time layer, space)
        type(FEISTY_type), intent(inout)  :: FEISTY       ! Daily data for the month 

        FEISTY%Sd_Fout_int = sum(diags%Sd_Fout)
        FEISTY%Ld_Repro_end = FEISTY%fish(Ld)%Repro

    end subroutine Calc_trans_layer

    ! subroutine init_store_MNTH(this, Ndays)
    !     type(Save_structure1D) :: this
    !     integer, intent(in) :: Ndays
    !     allocate(this%BE(Ndays))
    !     allocate(this%Sf(Ndays))
    !     allocate(this%Sp(Ndays))
    !     allocate(this%Sd(Ndays))
    !     allocate(this%Mf(Ndays))
    !     allocate(this%Mp(Ndays))
    !     allocate(this%Md(Ndays))
    !     allocate(this%Lp(Ndays))
    !     allocate(this%Ld(Ndays))
    !     allocate(this%Zcons_VS_dZm(Ndays))
    !     allocate(this%Zcons_VS_dZl(Ndays))
    ! end subroutine init_store_MNTH

    ! subroutine store_MNTH(this, that, iDAY)
    !     type(Save_structure1D) :: this
    !     type(FEISTY_type) :: that
    !     integer, intent(in) :: iDAY
    !     this%BE(iDAY) = that%BE%B
    !     this%Sf(iDAY) = that%Sf%B
    !     this%Sp(iDAY) = that%Sp%B
    !     this%Sd(iDAY) = that%Sd%B
    !     this%Mf(iDAY) = that%Mf%B
    !     this%Mp(iDAY) = that%Mp%B
    !     this%Md(iDAY) = that%Md%B
    !     this%Lp(iDAY) = that%Lp%B
    !     this%Ld(iDAY) = that%Ld%B
    !     this%Zcons_VS_dZm(iDay) = that%Zcons_VS_dZm
    !     this%Zcons_VS_dZl(iDay) = that%Zcons_VS_dZl
    ! end subroutine store_MNTH

    ! subroutine store_data_MNT(this, that, imonth, ilayer, ilath, ilongh, Ndays)
    !     type(Save_structure4D) :: this         ! Storage (Space, month)
    !     type(Save_structure1D) :: that         ! Daily data for the month 
    !     integer, intent(in) :: imonth, ilayer, ilath, ilongh, Ndays

    !     ! Store the average biomass of each group for the month
    !     this%BE(imonth, ilayer, ilath, ilongh) = sum(that%BE)/Ndays
    !     this%Sf(imonth, ilayer, ilath, ilongh) = sum(that%Sf)/Ndays
    !     this%Sp(imonth, ilayer, ilath, ilongh) = sum(that%Sp)/Ndays
    !     this%Sd(imonth, ilayer, ilath, ilongh) = sum(that%Sd)/Ndays
    !     this%Mf(imonth, ilayer, ilath, ilongh) = sum(that%Mf)/Ndays
    !     this%Mp(imonth, ilayer, ilath, ilongh) = sum(that%Mp)/Ndays
    !     this%Md(imonth, ilayer, ilath, ilongh) = sum(that%Md)/Ndays
    !     this%Lp(imonth, ilayer, ilath, ilongh) = sum(that%Lp)/Ndays
    !     this%Ld(imonth, ilayer, ilath, ilongh) = sum(that%Ld)/Ndays
    !     this%Zcons_VS_dZm(imonth, ilayer, ilath, ilongh) = sum(that%Zcons_VS_dZm)/Ndays
    !     this%Zcons_VS_dZl(imonth, ilayer, ilath, ilongh) = sum(that%Zcons_VS_dZl)/Ndays

    !     ! Deallocating the vectors to store next month daily values: 
    !     deallocate(that%BE)
    !     deallocate(that%Sf)
    !     deallocate(that%Sp)
    !     deallocate(that%Sd)
    !     deallocate(that%Mf)
    !     deallocate(that%Mp)
    !     deallocate(that%Md)
    !     deallocate(that%Lp)
    !     deallocate(that%Ld)
    !     deallocate(that%Zcons_VS_dZm)
    !     deallocate(that%Zcons_VS_dZl)
    ! end subroutine store_data_MNT


end module Structure