module Physiology
    use Parameters
    use Structure

    implicit none 
!:==================================================================================:!
!!!!!!!!!!!!! Calculation of the physiological parameters in FEISTY !!!!!!!!!!!!!!!!
!:==================================================================================:!


    contains
    subroutine Calc_FEISTY_Deriv(FEISTY)
    !:====================================================================== 
    ! Calcul temperature experience and then Q10
    ! Tb      : Temperature in Benthic         [°C]
    ! Tp      : Temperature in pelagic         [°C]
    ! tpel(i) : time spent in pelagic zone     [Ø]
    ! texp(i) : temperature experienced        [Ø]
    ! ke      : coeff on encouter T-dep fn     [°c-1]
    ! kmet    : coeff on metabolic T-dep fn    [°c-1]
    ! Calculation are made for pelagic (i=1) and demersal (i=2)
    !:====================================================================== 

        type(FEISTY_type), intent(inout) :: FEISTY
        real(dp), dimension(3) :: T_e = 0.0, T_met = 0.0
        real(dp) :: Cons_Zm, Cons_Zl, frac_Sf, frac_Sp, frac_Sd, frac_Mf, frac_Mp, pred_pel
        real(dp) :: r       ! benthic growth rate ((g/m2/d) / (g/m2))
        real(dp) :: pred    ! predation from demersals (g/m2/d)
        integer :: i

        T_e = dexp(ke * (FEISTY%Temp-10.0))      ! for encounter rate and Cmax
        T_met = dexp(kmet * (FEISTY%Temp-10.0))  ! for metabolism
        
        do i = 1, nFishGroup
            FEISTY%fish(i)%Tcorr_e = T_e(1)         ! Save temperature correction for encounter and cmax 
            FEISTY%fish(i)%Tcorr_met = T_met(1)     ! Save temperature correction for metabolism
        end do

    !:======================================================================
    ! Calculate the consumption for each group on zooplankton and fish 
    ! Test if consumption on zooplankton does not exceed the loss 
    ! to higher trophic level dZ
    ! V        : mass-specific Encounter rate               [m2 g−1 d−1]
    ! Tcorre_e : temperature correction                     [Ø]
    ! gamma    : coefficient for Encounter rate             [m2 g^(b_enc−1) d−1]
    ! w        : wet weight                                 [g]
    ! b_enc    : exponent for clearance rate                [Ø]
    ! cmax     : mass-specific maximum consumption          [d-1]
    ! h        : coefficient for maximum consumption        [d g^(b_cmax)]
    ! b_cmax   : exponent for maximum consumption           [Ø]
    ! f_       : feeding level on a specific group          [Ø]
    ! f        : total feeding level                        [Ø]
    ! pref_    : feeding preference for a specific group    [Ø]
    ! cons_    : consumption for a specific group           [d-1]
    ! cons     : total consumption                          [d-1]
    !:======================================================================
    ! dZ test should be remove for online simulation 
    !:======================================================================

        ! Calcul clearance rate: -------------------------------------------------------
        do i = 1, nFishGroup
            FEISTY%fish(i)%V = FEISTY%fish(i)%Tcorr_e * gamma * FEISTY%fish(i)%w **(-b_enc)/365.0    ! Calcul Clearance rate
            FEISTY%fish(i)%cmax = FEISTY%fish(i)%Tcorr_e * h * FEISTY%fish(i)%w **(-b_cmax)/365.0    ! Calcul Maximum consumption rate
            FEISTY%fish(i)%mu_a = Nat_mrt                                                            ! Calcul Natural Mortality
        end do 
        
       
        ! Calcul feeding level of MesoZoo prey: -------------------------------------------------
        ! Small fish only consume Medium zooplankton: (pref_Mz = 0.9 for 4P2Z and 1 for 4P4Z models)
        ! Small fish don't feed on Large zooplankton
        FEISTY%fish(1)%f_Zm = FEISTY%fish(1)%V * pref_Mz * FEISTY%mesozoo(1)%B/  & 
                            ((FEISTY%fish(1)%V* pref_Mz * FEISTY%mesozoo(1)%B) + FEISTY%fish(1)%cmax)
        FEISTY%fish(2)%f_Zm = FEISTY%fish(2)%V * pref_Mz * FEISTY%mesozoo(1)%B/  & 
                            ((FEISTY%fish(2)%V* pref_Mz * FEISTY%mesozoo(1)%B) + FEISTY%fish(2)%cmax)
        FEISTY%fish(3)%f_Zm = FEISTY%fish(3)%V * pref_Mz * FEISTY%mesozoo(1)%B/  & 
                            ((FEISTY%fish(3)%V* pref_Mz * FEISTY%mesozoo(1)%B) + FEISTY%fish(3)%cmax)
        
        ! Medium forage:
        FEISTY%fish(4)%f_Zm = FEISTY%fish(4)%V * pref_Mf_Mz * FEISTY%mesozoo(1)%B/((FEISTY%fish(4)%V* & 
            (pref_Mf_Mz * FEISTY%mesozoo(1)%B + pref_Mf_Lz * FEISTY%mesozoo(2)%B + pref_Mf_S* & 
            (FEISTY%fish(1)%B + FEISTY%fish(2)%B + FEISTY%fish(3)%B))) + FEISTY%fish(4)%cmax)

        FEISTY%fish(4)%f_Zl = FEISTY%fish(4)%V * pref_Mf_Lz * FEISTY%mesozoo(2)%B/((FEISTY%fish(4)%V* & 
            (pref_Mf_Mz * FEISTY%mesozoo(1)%B + pref_Mf_Lz * FEISTY%mesozoo(2)%B + pref_Mf_S* & 
            (FEISTY%fish(1)%B + FEISTY%fish(2)%B + FEISTY%fish(3)%B))) + FEISTY%fish(4)%cmax)
            
        FEISTY%fish(4)%f_Sf = FEISTY%fish(4)%V *pref_Mf_S* FEISTY%fish(1)%B/((FEISTY%fish(4)%V* &
            (pref_Mf_Mz * FEISTY%mesozoo(1)%B + pref_Mf_Lz * FEISTY%mesozoo(2)%B + pref_Mf_S* & 
            (FEISTY%fish(1)%B + FEISTY%fish(2)%B + FEISTY%fish(3)%B))) + FEISTY%fish(4)%cmax)

        FEISTY%fish(4)%f_Sp = FEISTY%fish(4)%V *pref_Mf_S* FEISTY%fish(2)%B/((FEISTY%fish(4)%V* &
            (pref_Mf_Mz * FEISTY%mesozoo(1)%B + pref_Mf_Lz * FEISTY%mesozoo(2)%B + pref_Mf_S* & 
            (FEISTY%fish(1)%B + FEISTY%fish(2)%B + FEISTY%fish(3)%B))) + FEISTY%fish(4)%cmax)

        FEISTY%fish(4)%f_Sd = FEISTY%fish(4)%V *pref_Mf_S* FEISTY%fish(3)%B/((FEISTY%fish(4)%V* &
            (pref_Mf_Mz * FEISTY%mesozoo(1)%B + pref_Mf_Lz * FEISTY%mesozoo(2)%B + pref_Mf_S* & 
            (FEISTY%fish(1)%B + FEISTY%fish(2)%B + FEISTY%fish(3)%B))) + FEISTY%fish(4)%cmax) 
                 
        FEISTY%fish(4)%f = FEISTY%fish(4)%f_Zm + FEISTY%fish(4)%f_Zl + FEISTY%fish(4)%f_Sf + & 
                           FEISTY%fish(4)%f_Sp + FEISTY%fish(4)%f_Sd
        
        ! Medium pelagic:
        FEISTY%fish(5)%f_Zm = FEISTY%fish(5)%V * pref_Mp_Mz * FEISTY%mesozoo(1)%B/ & 
            ((FEISTY%fish(5)%V* (pref_Mp_Mz * FEISTY%mesozoo(1)%B + pref_Mp_Lz * FEISTY%mesozoo(2)%B + &
            pref_Mp_S * (FEISTY%fish(1)%B + FEISTY%fish(2)%B + FEISTY%fish(3)%B))) + FEISTY%fish(5)%cmax)

        FEISTY%fish(5)%f_Zl = FEISTY%fish(5)%V * pref_Mp_Lz * FEISTY%mesozoo(2)%B/ &
            ((FEISTY%fish(5)%V* (pref_Mp_Mz * FEISTY%mesozoo(1)%B+ pref_Mp_Lz * FEISTY%mesozoo(2)%B + & 
            pref_Mp_S*(FEISTY%fish(1)%B + FEISTY%fish(2)%B + FEISTY%fish(3)%B))) + FEISTY%fish(5)%cmax)

        FEISTY%fish(5)%f_Sf = FEISTY%fish(5)%V *pref_Mp_S* FEISTY%fish(1)%B/ &
            ((FEISTY%fish(5)%V* (pref_Mp_Mz * FEISTY%mesozoo(1)%B + pref_Mp_Lz * FEISTY%mesozoo(2)%B + &
            pref_Mp_S*(FEISTY%fish(1)%B + FEISTY%fish(2)%B + FEISTY%fish(3)%B))) + FEISTY%fish(5)%cmax)

        FEISTY%fish(5)%f_Sp = FEISTY%fish(5)%V *pref_Mp_S* FEISTY%fish(2)%B/ &
            ((FEISTY%fish(5)%V* (pref_Mp_Mz * FEISTY%mesozoo(1)%B+ pref_Mp_Lz * FEISTY%mesozoo(2)%B + & 
            pref_Mp_S*(FEISTY%fish(1)%B + FEISTY%fish(2)%B + FEISTY%fish(3)%B))) + FEISTY%fish(5)%cmax)

        FEISTY%fish(5)%f_Sd = FEISTY%fish(5)%V *pref_Mp_S* FEISTY%fish(3)%B/ &
            ((FEISTY%fish(5)%V* (pref_Mp_Mz * FEISTY%mesozoo(1)%B+ pref_Mp_Lz * FEISTY%mesozoo(2)%B + & 
            pref_Mp_S*(FEISTY%fish(1)%B + FEISTY%fish(2)%B + FEISTY%fish(3)%B))) + FEISTY%fish(5)%cmax)
        
        FEISTY%fish(5)%f = FEISTY%fish(5)%f_Zm + FEISTY%fish(5)%f_Zl + FEISTY%fish(5)%f_Sf + & 
                           FEISTY%fish(5)%f_Sp + FEISTY%fish(5)%f_Sd

        ! Medium Demersals only eat benthos resource: 
        FEISTY%fish(6)%f_BE = FEISTY%fish(6)%V *pref_Md_BE * FEISTY%benthos(1)%B/ &
                             ((FEISTY%fish(6)%V * pref_Md_BE * FEISTY%benthos(1)%B) + FEISTY%fish(6)%cmax)
        FEISTY%fish(6)%f = FEISTY%fish(6)%f_BE

        ! Large pelagics: 
        FEISTY%fish(7)%f_Mf = FEISTY%fish(7)%V * pref_Lp_Mf * FEISTY%fish(4)%B / &
            (FEISTY%fish(7)%V* (pref_Lp_Mf * FEISTY%fish(4)%B + pref_Lp_Mp * FEISTY%fish(5)%B) + FEISTY%fish(7)%cmax)

        FEISTY%fish(7)%f_Mp = FEISTY%fish(7)%V * pref_Lp_Mp * FEISTY%fish(5)%B / &
            (FEISTY%fish(7)%V* (pref_Lp_Mf * FEISTY%fish(4)%B + pref_Lp_Mp * FEISTY%fish(5)%B) + FEISTY%fish(7)%cmax)

        FEISTY%fish(7)%f = FEISTY%fish(7)%f_Mf + FEISTY%fish(7)%f_Mp

        ! Large Demersal: 
        ! If large demersal don't spend time in pelagic zone then predation on forage and pelagics = 0; 
        ! if (FEISTY%tpel_Ld == 0.0) then 
        !     pred_pel = 0.0
        ! else 
            pred_pel = 1.0
        ! end if  

        FEISTY%fish(8)%f_Mf = FEISTY%fish(8)%V * pred_pel * pref_Ld_Mf * FEISTY%fish(4)%B /(FEISTY%fish(8)%V * &
            (pred_pel * pref_Ld_Mf * FEISTY%fish(4)%B + pred_pel * pref_Ld_Mp * FEISTY%fish(5)%B + &
             pref_Ld_Md * FEISTY%fish(6)%B + pref_Ld_BE * FEISTY%benthos(1)%B) + FEISTY%fish(8)%cmax)

        FEISTY%fish(8)%f_Mp = pred_pel * FEISTY%fish(8)%V * pred_pel * pref_Ld_Mp * FEISTY%fish(5)%B /(FEISTY%fish(8)%V* &
            (pred_pel * pref_Ld_Mf * FEISTY%fish(4)%B + pred_pel * pref_Ld_Mp * FEISTY%fish(5)%B + &
             pref_Ld_Md * FEISTY%fish(6)%B + pref_Ld_BE * FEISTY%benthos(1)%B) + FEISTY%fish(8)%cmax)

        FEISTY%fish(8)%f_Md = FEISTY%fish(8)%V * pref_Ld_Md * FEISTY%fish(6)%B /(FEISTY%fish(8)%V* &
            (pred_pel * pref_Ld_Mf * FEISTY%fish(4)%B + pred_pel * pref_Ld_Mp * FEISTY%fish(5)%B + & 
            pref_Ld_Md * FEISTY%fish(6)%B + pref_Ld_BE * FEISTY%benthos(1)%B) + FEISTY%fish(8)%cmax)

        FEISTY%fish(8)%f_BE = FEISTY%fish(8)%V * pref_Ld_BE * FEISTY%benthos(1)%B /(FEISTY%fish(8)%V* &
            (pred_pel * pref_Ld_Mf * FEISTY%fish(4)%B + pred_pel * pref_Ld_Mp * FEISTY%fish(5)%B + & 
            pref_Ld_Md * FEISTY%fish(6)%B + pref_Ld_BE * FEISTY%benthos(1)%B) + FEISTY%fish(8)%cmax)

        FEISTY%fish(8)%f = FEISTY%fish(8)%f_Mf + FEISTY%fish(8)%f_Mp + FEISTY%fish(8)%f_Md + FEISTY%fish(8)%f_BE

        !:====================================================================================:!
        !                                Consumption per group                                 !
        !:====================================================================================:!
        
        ! Calcul consumption rate of MesoZoo: -------------------------------------------------
        ! Used for estimation of the fraction of zooplankton biomass consumed: (m-2 d-1)
        FEISTY%fish(1)%cons_Mz = FEISTY%fish(1)%f_Zm * FEISTY%fish(1)%cmax 
        FEISTY%fish(2)%cons_Mz = FEISTY%fish(2)%f_Zm * FEISTY%fish(2)%cmax
        FEISTY%fish(3)%cons_Mz = FEISTY%fish(3)%f_Zm * FEISTY%fish(3)%cmax
        ! Medium on Mz
        FEISTY%fish(4)%cons_Mz = FEISTY%fish(4)%f_Zm * FEISTY%fish(4)%cmax
        FEISTY%fish(5)%cons_Mz = FEISTY%fish(5)%f_Zm * FEISTY%fish(5)%cmax
        ! Medium on Lz
        FEISTY%fish(4)%cons_Lz = FEISTY%fish(4)%f_Zl * FEISTY%fish(4)%cmax
        FEISTY%fish(5)%cons_Lz = FEISTY%fish(5)%f_Zl * FEISTY%fish(5)%cmax

        ! Calcul consumption for each fish group: ----------------------------------------------
        ! Used to calculate the predation mortality on each group: 
        ! Medium forage consumption on fish
        FEISTY%fish(4)%cons_Sf = FEISTY%fish(4)%f_Sf * FEISTY%fish(4)%cmax
        FEISTY%fish(4)%cons_Sp = FEISTY%fish(4)%f_Sp * FEISTY%fish(4)%cmax 
        FEISTY%fish(4)%cons_Sd = FEISTY%fish(4)%f_Sd * FEISTY%fish(4)%cmax
        ! Medium Pelagic consumption on fish
        FEISTY%fish(5)%cons_Sf = FEISTY%fish(5)%f_Sf * FEISTY%fish(5)%cmax
        FEISTY%fish(5)%cons_Sp = FEISTY%fish(5)%f_Sp * FEISTY%fish(5)%cmax 
        FEISTY%fish(5)%cons_Sd = FEISTY%fish(5)%f_Sd * FEISTY%fish(5)%cmax

        ! Medium Demersal consumption on fish
        FEISTY%fish(6)%cons_BE = FEISTY%fish(6)%f_BE * FEISTY%fish(6)%cmax
        ! Large Pelagic:
        FEISTY%fish(7)%cons_Mf = FEISTY%fish(7)%f_Mf * FEISTY%fish(7)%cmax
        FEISTY%fish(7)%cons_Mp = FEISTY%fish(7)%f_Mp * FEISTY%fish(7)%cmax
        ! Large Demersal: 
        FEISTY%fish(8)%cons_Mf = FEISTY%fish(8)%f_Mf * FEISTY%fish(8)%cmax
        FEISTY%fish(8)%cons_Mp = FEISTY%fish(8)%f_Mp * FEISTY%fish(8)%cmax
        FEISTY%fish(8)%cons_Md = FEISTY%fish(8)%f_Md * FEISTY%fish(8)%cmax
        FEISTY%fish(8)%cons_BE = FEISTY%fish(8)%f_BE * FEISTY%fish(8)%cmax

        ! Fraction of zooplankton biomass consumed:----------------------------------------
        ! Calcul total consumption for each Zooplankton group:
        Cons_Zm = (FEISTY%fish(1)%cons_Mz * FEISTY%fish(1)%B + FEISTY%fish(2)%cons_Mz * FEISTY%fish(2)%B + &
                   FEISTY%fish(3)%cons_Mz * FEISTY%fish(3)%B + FEISTY%fish(4)%cons_Mz * FEISTY%fish(4)%B + &
                   FEISTY%fish(5)%cons_Mz * FEISTY%fish(5)%B)
        Cons_Zl = (FEISTY%fish(4)%cons_Lz * FEISTY%fish(4)%B + FEISTY%fish(5)%cons_Lz * FEISTY%fish(5)%B)
        
        ! Calcul of fraction of Zoo consumption over estimated zoop consumption:
        FEISTY%mesozoo(1)%Zcons_VS_dZ = Cons_Zm/(FEISTY%mesozoo(1)%dz + eps)
        FEISTY%mesozoo(2)%Zcons_VS_dZ = Cons_Zl/(FEISTY%mesozoo(2)%dz + eps)

        ! If calculated consumtiion is higher than estimated recalcul the fraction of Z consumed 
        ! depending on every group relative fraction of consumtion on Z. 
        ! Mz: 
        if (Cons_Zm > FEISTY%mesozoo(1)%dz .and. prod_constrained) then
            ! Calcul fraction of consumption over total consumption of zoo
            frac_Sf = FEISTY%fish(1)%cons_Mz * FEISTY%fish(1)%B / (FEISTY%fish(1)%cons_Mz * FEISTY%fish(1)%B + &
                     FEISTY%fish(2)%cons_Mz * FEISTY%fish(2)%B + &
                     FEISTY%fish(3)%cons_Mz * FEISTY%fish(3)%B + FEISTY%fish(4)%cons_Mz * FEISTY%fish(4)%B + &
                     FEISTY%fish(5)%cons_Mz * FEISTY%fish(5)%B)
            frac_Sp = FEISTY%fish(2)%cons_Mz * FEISTY%fish(2)%B / (FEISTY%fish(1)%cons_Mz * FEISTY%fish(1)%B + &
                    FEISTY%fish(2)%cons_Mz * FEISTY%fish(2)%B + &
                    FEISTY%fish(3)%cons_Mz * FEISTY%fish(3)%B + FEISTY%fish(4)%cons_Mz * FEISTY%fish(4)%B + &
                    FEISTY%fish(5)%cons_Mz * FEISTY%fish(5)%B)
            frac_Sd = FEISTY%fish(3)%cons_Mz * FEISTY%fish(3)%B / (FEISTY%fish(1)%cons_Mz * FEISTY%fish(1)%B + & 
                    FEISTY%fish(2)%cons_Mz * FEISTY%fish(2)%B + &
                    FEISTY%fish(3)%cons_Mz * FEISTY%fish(3)%B + FEISTY%fish(4)%cons_Mz * FEISTY%fish(4)%B + &
                    FEISTY%fish(5)%cons_Mz * FEISTY%fish(5)%B)
            frac_Mf = FEISTY%fish(4)%cons_Mz * FEISTY%fish(4)%B / (FEISTY%fish(1)%cons_Mz * FEISTY%fish(1)%B + & 
                    FEISTY%fish(2)%cons_Mz * FEISTY%fish(2)%B + &
                    FEISTY%fish(3)%cons_Mz * FEISTY%fish(3)%B + FEISTY%fish(4)%cons_Mz * FEISTY%fish(4)%B + &
                    FEISTY%fish(5)%cons_Mz * FEISTY%fish(5)%B)
            frac_Mp = FEISTY%fish(5)%cons_Mz * FEISTY%fish(5)%B / (FEISTY%fish(1)%cons_Mz * FEISTY%fish(1)%B + & 
                    FEISTY%fish(2)%cons_Mz * FEISTY%fish(2)%B + &
                    FEISTY%fish(3)%cons_Mz * FEISTY%fish(3)%B + FEISTY%fish(4)%cons_Mz * FEISTY%fish(4)%B + &
                    FEISTY%fish(5)%cons_Mz * FEISTY%fish(5)%B)

            ! Actual consumption as the faction of consumption * dz: -------------------------
            ! Divide the biomass consumed by the biomass of the predator to get a per g of predator rate. 
            FEISTY%fish(1)%cons_Mz = frac_Sf * FEISTY%mesozoo(1)%dz / FEISTY%fish(1)%B
            FEISTY%fish(2)%cons_Mz = frac_Sp * FEISTY%mesozoo(1)%dz / FEISTY%fish(2)%B
            FEISTY%fish(3)%cons_Mz = frac_Sd * FEISTY%mesozoo(1)%dz / FEISTY%fish(3)%B
            FEISTY%fish(4)%cons_Mz = frac_Mf * FEISTY%mesozoo(1)%dz / FEISTY%fish(4)%B
            FEISTY%fish(5)%cons_Mz = frac_Mp * FEISTY%mesozoo(1)%dz / FEISTY%fish(5)%B
        end if  
        
        ! Lz:
        if (Cons_Zl > FEISTY%mesozoo(2)%dz .and. prod_constrained) then
            ! Calcul fraction of consumption over total consumption of zoo
            frac_Mf = FEISTY%fish(4)%cons_Lz * FEISTY%fish(4)%B / & 
                     (FEISTY%fish(4)%cons_Lz * FEISTY%fish(4)%B + FEISTY%fish(5)%cons_Lz * FEISTY%fish(5)%B)
            frac_Mp = FEISTY%fish(5)%cons_Lz * FEISTY%fish(5)%B / & 
                     (FEISTY%fish(4)%cons_Lz * FEISTY%fish(4)%B + FEISTY%fish(5)%cons_Lz * FEISTY%fish(5)%B)

            ! Actual consumption as the faction of consumption * dz: -------------------------
            ! Divide the biomass consumed by the biomass of the predator to get a per g of predator rate. 
            FEISTY%fish(4)%cons_Lz = frac_Mf * FEISTY%mesozoo(2)%dz / FEISTY%fish(4)%B
            FEISTY%fish(5)%cons_Lz = frac_Mp * FEISTY%mesozoo(2)%dz / FEISTY%fish(5)%B
        end if 

        ! Total consumption rate with adjusted consumption on zooplankton: ------------------
        FEISTY%fish(1)%cons = FEISTY%fish(1)%cons_Mz
        FEISTY%fish(2)%cons = FEISTY%fish(2)%cons_Mz
        FEISTY%fish(3)%cons = FEISTY%fish(3)%cons_Mz
        FEISTY%fish(4)%cons = FEISTY%fish(4)%cons_Mz + FEISTY%fish(4)%cons_Lz + FEISTY%fish(4)%cons_Sf + & 
                              FEISTY%fish(4)%cons_Sp + FEISTY%fish(4)%cons_Sd 
        FEISTY%fish(5)%cons = FEISTY%fish(5)%cons_Mz + FEISTY%fish(5)%cons_Lz + FEISTY%fish(5)%cons_Sf + & 
                              FEISTY%fish(5)%cons_Sp + FEISTY%fish(5)%cons_Sd

        ! Recalculate feeding level based on new consumption:--------------------------------
        FEISTY%fish(1)%f = FEISTY%fish(1)%cons / FEISTY%fish(1)%cmax
        FEISTY%fish(2)%f = FEISTY%fish(2)%cons / FEISTY%fish(2)%cmax
        FEISTY%fish(3)%f = FEISTY%fish(3)%cons / FEISTY%fish(3)%cmax
        FEISTY%fish(4)%f = FEISTY%fish(4)%cons / FEISTY%fish(4)%cmax
        FEISTY%fish(5)%f = FEISTY%fish(5)%cons / FEISTY%fish(5)%cmax
        
        ! The folowing groups don't feed on zooplankton: ------------------------------------
        FEISTY%fish(6)%cons = FEISTY%fish(6)%cons_BE
        FEISTY%fish(7)%cons = FEISTY%fish(7)%f * FEISTY%fish(7)%cmax
        FEISTY%fish(8)%cons = FEISTY%fish(8)%f * FEISTY%fish(8)%cmax

    !:======================================================================
    ! Calculate the mortality for fish functional group 
    ! Fishing mortality is assumed constant and nul
    ! mu_p : Predation from fish      [m-2 d-1]
    ! mu_f : Fishing mortality ( = 0) [m-2 d-1]
    ! mu_a : Natural mortality        [m-2 d-1]
    !:======================================================================

        ! Calcul Predation mortality: -----------------------------------------------
        ! mu_p [m-2 d-1]
        FEISTY%fish(1)%mu_p = (FEISTY%fish(5)%cons_Sf * FEISTY%fish(5)%B + FEISTY%fish(4)%cons_Sf * &
                                 FEISTY%fish(4)%B) / FEISTY%fish(1)%B
        FEISTY%fish(2)%mu_p = (FEISTY%fish(5)%cons_Sp * FEISTY%fish(5)%B + FEISTY%fish(4)%cons_Sp * &
                                 FEISTY%fish(4)%B) / FEISTY%fish(2)%B
        FEISTY%fish(3)%mu_p = (FEISTY%fish(5)%cons_Sd * FEISTY%fish(5)%B + FEISTY%fish(4)%cons_Sd * &
                                 FEISTY%fish(4)%B) / FEISTY%fish(3)%B
        FEISTY%fish(4)%mu_p = (FEISTY%fish(7)%cons_Mf * FEISTY%fish(7)%B + FEISTY%fish(8)%cons_Mf * &
                                 FEISTY%fish(8)%B) / FEISTY%fish(4)%B
        FEISTY%fish(5)%mu_p = (FEISTY%fish(7)%cons_Mp * FEISTY%fish(7)%B + FEISTY%fish(8)%cons_Mp * &
                                 FEISTY%fish(8)%B) / FEISTY%fish(5)%B
        FEISTY%fish(6)%mu_p = (FEISTY%fish(7)%cons_Md * FEISTY%fish(7)%B + FEISTY%fish(8)%cons_Md * &
                                 FEISTY%fish(8)%B) / FEISTY%fish(6)%B
        FEISTY%fish(7)%mu_p = 0
        FEISTY%fish(8)%mu_p = 0

        ! Calcul Natural mortality:  -----------------------------------------------
        ! Several ways to consider the natural mortality: 
        ! - constant 
        ! - size dependent 
        ! - size and temperature dependent. 
        ! Note that the temperature effect would be and increase of mortality due to 
        ! the effect of temperature on the physiology and not on the increase/decrease of predation resulting
        ! from physiological changes of other groups. 
        !  ------------------------------------------------------------------------
    
        ! Calcul Fishing mortality!  ----------------------------------------------
        ! Small fish are not fished
        ! Medium forage are fished at 1 
        ! Large fish are fished at 1 
        !  ------------------------------------------------------------------------
        FEISTY%fish(4)%mu_f = Frate * Aselct
        FEISTY%fish(5)%mu_f = Frate * Jselct * Aselct
        FEISTY%fish(6)%mu_f = Frate * Jselct * Aselct
        FEISTY%fish(7)%mu_f = Frate * Aselct
        FEISTY%fish(8)%mu_f = Frate * Aselct
    
    !:======================================================================
    ! Calculate the Metabolic loss as a function of: ----------------------
    ! met        : mass-specific Metabolic loss                      [d-1] 
    ! w          : wet weight                                        [g]  
    ! tcorr_met  : temperature correction                            []
    ! a_mmet     : coefficient for mass-specific metabolic loss      [d-1 g^(b_met)]
    ! b_met      : exponent for mass-specific metabolic loss         []
    ! Calcul Available energy of growth and reproduction : ----------------
    ! eps_a      : Assimilation efficiency            []
    ! met        : mass-specific metabolic cost       [d-1]     
    ! Cons       : mass-specific total consumption    [d-1]
    !:======================================================================
        
        do i = 1, nFishGroup
            FEISTY%fish(i)%mu = FEISTY%fish(i)%mu_p + FEISTY%fish(i)%mu_a + FEISTY%fish(i)%mu_f         ! Total mortality 
            FEISTY%fish(i)%met = FEISTY%fish(i)%Tcorr_met * a_met * FEISTY%fish(i)%w ** (-b_met) / 365  ! Metabolic losses 
            FEISTY%fish(i)%E_A = eps_a * FEISTY%fish(i)%cons - FEISTY%fish(i)%met                       ! Available Energy 
            FEISTY%fish(i)%Fout = ((kappa(i) * FEISTY%fish(i)%E_A) - FEISTY%fish(i)%mu ) / &            ! Flux out of size class
            & (1 - (Z(i) ** (1 - (FEISTY%fish(i)%mu / (kappa(i) * FEISTY%fish(i)%E_A)))) + eps) 
            FEISTY%fish(i)%Fout = max(min(FEISTY%fish(i)%Fout, FEISTY%fish(i)%E_A), zero)               ! If Fout is higher than E_a take E_a, and 0 is negative
        end do 

    !:======================================================================
    ! Calcul the reproductive flux of biomass 
    ! Repro   : rate (of biomass) invested in reproduction after reproduction loss [m-2 d-1]
    ! eps_R   : Reproduction efficiency 
    ! We DO NOT assum that the biomass that is going out of the last size class (Adult)
    ! is converted to reproduction to account for a fraction of individual dying after 
    ! reproduction. 
    !:======================================================================

        ! Only Medium forage, large pelagic and demersal reproduce: 
        FEISTY%fish(4)%Repro = max((1.0 - kappa_a) * FEISTY%fish(4)%E_A + FEISTY%fish(4)%Fout, 0.0)
        FEISTY%fish(7)%Repro = max((1.0 - kappa_a) * FEISTY%fish(7)%E_A + FEISTY%fish(7)%Fout, 0.0)
        FEISTY%fish(8)%Repro = max((1.0 - kappa_a) * FEISTY%fish(8)%E_A + FEISTY%fish(8)%Fout, 0.0)

        ! Fout for Adult are set up to 0: (sub_rep function in matlab)
        FEISTY%fish(4)%Fout = 0 
        FEISTY%fish(7)%Fout = 0
        FEISTY%fish(8)%Fout = 0

    !:======================================================================
    ! Calcul the Benthic biomass from detritus flux to benthic 
    ! Classic logistic growth rate
    ! The calculation has to be done after the derivative have been calculated 
    ! for each fish group ! 
    !:======================================================================
    ! FEISTY%benthos(i)%B          : Benthic biomass 
    ! Bent_eff =  0.075  :  Benthic Efficiency from detritus to benthic biomass
    ! CC = 80            : Carring Capacity for benthic chemostat
    !:======================================================================

        pred = FEISTY%fish(6)%cons_BE * FEISTY%fish(6)%B + FEISTY%fish(8)%cons_BE * FEISTY%fish(8)%B
        r = Bent_eff * FEISTY%det / FEISTY%benthos(1)%B 
        FEISTY%benthos(1)%B = FEISTY%benthos(1)%B + r * FEISTY%benthos(1)%B * (1 - FEISTY%benthos(1)%B/CC) - pred 


    !:====================================================================== 
    ! Calculate the derivative and New biomass for each fish group
    !:====================================================================== 
    ! - Repro    : Recruitment rate (from adult repro to hatching)  [m-2 d-1]
    ! - E_A      : Available energy for growth and  reproduction    [m-2 d-1]
    ! - mu       : Total mortality (Predation + Fishing + Natural)  [m-2 d-1]
    ! - Fout     : Flux out of the size class (growth)              [m-2 d-1]
    ! - B        : Biomass of the group                             [g m-2]
    ! - Delta_t  : Time step                                        [d]
    !:====================================================================== 
        !SF
        FEISTY%dBdt(1) = eps_R * FEISTY%fish(4)%Repro * FEISTY%fish(4)%B + & 
                        (FEISTY%fish(1)%E_A - FEISTY%fish(1)%Fout - FEISTY%fish(1)%mu) * FEISTY%fish(1)%B
        !SM
        FEISTY%dBdt(2) = eps_R * FEISTY%fish(7)%Repro * FEISTY%fish(7)%B + & 
                        (FEISTY%fish(2)%E_A - FEISTY%fish(2)%Fout - FEISTY%fish(2)%mu) * FEISTY%fish(2)%B
        ! Reproduction from Large demersal is equaly divided between the first 30 layers (about 100m depth): 
        ! for mass conservation: Fout is integrated Fout/Nlayer and repro = Ld_Repro_end/FEISTY%Nlayer
        !SD:
        if (largDemPel) then  ! Puts the large Demersals in the Pelagic Layer
            FEISTY%dBdt(3) = eps_R * FEISTY%fish(Ld)%Repro * &
                 & FEISTY%fish(Ld)%B + (FEISTY%fish(3)%E_A - FEISTY%fish(3)%Fout - FEISTY%fish(3)%mu) * FEISTY%fish(3)%B  
        else   ! Large Demersals inhabit only the bottom 
            FEISTY%dBdt(3) = eps_R * (FEISTY%Ld_Repro_end/FEISTY%Nlayer) * &
                 & FEISTY%fish(8)%B + (FEISTY%fish(3)%E_A - FEISTY%fish(3)%Fout - FEISTY%fish(3)%mu) * FEISTY%fish(3)%B  
        end if 

        ! Medium size (reproduction loss for Mf)
        FEISTY%dBdt(4) = FEISTY%fish(1)%Fout * FEISTY%fish(1)%B + (FEISTY%fish(4)%E_A - & 
                         FEISTY%fish(4)%Repro - FEISTY%fish(4)%mu) * FEISTY%fish(4)%B
        FEISTY%dBdt(5) = FEISTY%fish(2)%Fout * FEISTY%fish(2)%B + (FEISTY%fish(5)%E_A - & 
                         FEISTY%fish(5)%Fout  - FEISTY%fish(5)%mu) * FEISTY%fish(5)%B
        if (FEISTY%ilayer .eq. FEISTY%Nlayer) then ! use Sd_Fout_B_int for last layer 
            FEISTY%dBdt(6) = FEISTY%Sd_Fout_B_int + & 
                            (FEISTY%fish(6)%E_A - FEISTY%fish(6)%Fout  - FEISTY%fish(6)%mu) * FEISTY%fish(6)%B 
        else ! If not in last layer then demersal don't grow in water column (don't put Fout = 0.0 as we save the value later)
            FEISTY%dBdt(6) = 0.0
        endif 
        
        ! Large fish (reproduction Fout = 0) 
        FEISTY%dBdt(7) = FEISTY%fish(5)%Fout * FEISTY%fish(5)%B + & 
                         (FEISTY%fish(7)%E_A - FEISTY%fish(7)%Repro - FEISTY%fish(7)%mu) * FEISTY%fish(7)%B
        
        if (largDemPel) then 
            FEISTY%dBdt(8) = FEISTY%Md_Fout_end * FEISTY%Nlayer**(-1) * FEISTY%fish(6)%B + & 
                (FEISTY%fish(8)%E_A - FEISTY%fish(6)%Repro - FEISTY%fish(8)%mu) * FEISTY%fish(8)%B
        else 
            if (FEISTY%ilayer .eq. FEISTY%Nlayer) then
                FEISTY%dBdt(8) = FEISTY%fish(6)%Fout * FEISTY%fish(6)%B + & 
                    (FEISTY%fish(8)%E_A - FEISTY%fish(6)%Repro - FEISTY%fish(8)%mu) * FEISTY%fish(8)%B 
            else 
                FEISTY%dBdt(8) = 0.0
            endif
        endif
        
        !:======================================================================
        ! Calcul Benthic chemostat and derivative from detritus flux to benthic 
        !:======================================================================
        ! FEISTY%benthos(i)%B          : Benthic biomass 
        ! Bent_eff =  0.075  : Benthic Efficiency from detritus to benthic biomass
        ! CC = 80            : Carring Capacity for benthic chemostat
        !:======================================================================
        do i = 1, nBenthos
            pred = FEISTY%fish(Md)%cons_BE * FEISTY%fish(Md)%B + FEISTY%fish(Ld)%cons_BE * FEISTY%fish(Ld)%B
            r = Bent_eff * FEISTY%det / FEISTY%benthos(i)%B 
            FEISTY%benthos(i)%B = FEISTY%benthos(i)%B + r * FEISTY%benthos(i)%B * (1 - FEISTY%benthos(i)%B/CC) - pred 
        enddo

        ! New biomass : ------------------------------------------
        do i = 1, nFishGroup
            FEISTY%fish(i)%B = FEISTY%fish(i)%B + Delta_t * FEISTY%dBdt(i)  ! Euler schem
            ! Check for neg and na values 
            if (FEISTY%fish(i)%B <= zero .or. isnan(FEISTY%fish(i)%B)) then 
                FEISTY%fish(i)%B = 1.0d-5
            end if 
        end do 

        do i = 1, nBenthos
            if (FEISTY%benthos(i)%B <= zero .or. isnan(FEISTY%benthos(i)%B)) then 
                FEISTY%benthos(i)%B = 1.0d-5
            end if 
        enddo

        ! Print all diagnostics used in FEISTY 
        if (diagnostic) then 
             CALL Print_FEISTY_diagnostic(FEISTY)
        end if 

    end subroutine Calc_FEISTY_Deriv
    
end module Physiology
