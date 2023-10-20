module Physiology
    use Parameters
    use Structure
    implicit none 
!:==================================================================================
!!!!!!!!!!!!! Calculation of the physiological parameters in FEISTY !!!!!!!!!!!!!!!!
!:================================================================================== 


    contains
    subroutine Calc_Q10(this)
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

        type(Structure_group), intent(inout) :: this
        real(dp), dimension(2) :: Texp, T_e, T_met, tpel 
        real(dp) :: biop, biod
        integer :: i
        tpel(1) = 1.0 ! Pelagic type of life (100% time spent in the pelagic zone)
        tpel(2) = 0.0 ! benthic type of lige (0% time spent in the pelagic zone)
        ! Other calculation for time in pelagic for demersals taking into account prey biomass: 
        
        DO i = 1, 2
            ! Calc of the average temperature experienced 
            Texp(i) = (this%Tp * tpel(i)) + (this%Tb*(1.0-tpel(i)))
        
            ! Calc Temperature correction  
            T_e(i) = exp(ke * (Texp(i)-10.0))      ! for encounter rate and Cmax
            T_met(i) = exp(kmet * (Texp(i)-10.0))  ! for metabolism
        END DO 
        
        ! Save temperature correction for encounter and cmax 
        this%Sf%Tcorr_e = T_e(1)
        this%Sp%Tcorr_e = T_e(1)
        this%Sd%Tcorr_e = T_e(1)
        this%Mf%Tcorr_e = T_e(1)
        this%Mp%Tcorr_e = T_e(1)
        this%Md%Tcorr_e = T_e(2)
        this%Lp%Tcorr_e = T_e(1)
        this%Ld%Tcorr_e = T_e(2)

        ! Save temperature correction for metabolism
        this%Sf%Tcorr_met = T_met(1)
        this%Sp%Tcorr_met = T_met(1)
        this%Sd%Tcorr_met = T_met(1)
        this%Mf%Tcorr_met = T_met(1)
        this%Mp%Tcorr_met = T_met(1)
        this%Md%Tcorr_met = T_met(2)
        this%Lp%Tcorr_met = T_met(1)
        this%Ld%Tcorr_met = T_met(2)
    end subroutine Calc_Q10

    
    subroutine Consumption(This)
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
        class(Structure_group), intent(inout) :: this
        real(dp) :: Cons_Zm, frac_Sf, frac_Sp, frac_Sd, frac_Mf, frac_Mp

        ! Calcul clearance rate: -------------------------------------------------------
        this%Sf%V = this%Sf%Tcorr_e * gamma * this%Sf%w **(-b_enc)/365.0
        this%Sp%V = this%Sp%Tcorr_e * gamma * this%Sp%w **(-b_enc)/365.0
        this%Sd%V = this%Sd%Tcorr_e * gamma * this%Sd%w **(-b_enc)/365.0
        this%Mf%V = this%Mf%Tcorr_e * gamma * this%Mf%w **(-b_enc)/365.0
        this%Mp%V = this%Mp%Tcorr_e * gamma * this%Mp%w **(-b_enc)/365.0
        this%Md%V = this%Md%Tcorr_e * gamma * this%Md%w **(-b_enc)/365.0
        this%Lp%V = this%Lp%Tcorr_e * gamma * this%Lp%w **(-b_enc)/365.0
        this%Ld%V = this%Ld%Tcorr_e * gamma * this%Ld%w **(-b_enc)/365.0
                
        ! Calcul cmax: ------------------------------------------------------------------
        this%Sf%cmax = this%Sf%Tcorr_e * h * this%Sf%w **(-b_cmax)/365.0
        this%Sp%cmax = this%Sp%Tcorr_e * h * this%Sp%w **(-b_cmax)/365.0
        this%Sd%cmax = this%Sd%Tcorr_e * h * this%Sd%w **(-b_cmax)/365.0
        this%Mf%cmax = this%Mf%Tcorr_e * h * this%Mf%w **(-b_cmax)/365.0
        this%Mp%cmax = this%Mp%Tcorr_e * h * this%Mp%w **(-b_cmax)/365.0
        this%Md%cmax = this%Md%Tcorr_e * h * this%Md%w **(-b_cmax)/365.0
        this%Lp%cmax = this%Lp%Tcorr_e * h * this%Lp%w **(-b_cmax)/365.0
        this%Ld%cmax = this%Ld%Tcorr_e * h * this%Ld%w **(-b_cmax)/365.0
       
        ! Calcul feeding level of MesoZoo prey: -------------------------------------------------
        ! Small fish only consume zooplankton:
        this%Sf%f_Zm = this%Sf%V * pref_Mz * this%Mz%B/((this%Sf%V* pref_Mz * this%Mz%B) + this%Sf%cmax)
        this%Sp%f_Zm = this%Sp%V * pref_Mz * this%Mz%B/((this%Sp%V* pref_Mz * this%Mz%B) + this%Sp%cmax)
        this%Sd%f_Zm = this%Sd%V * pref_Mz * this%Mz%B/((this%Sd%V* pref_Mz * this%Mz%B) + this%Sd%cmax)
        
        ! Medium forage:
        this%Mf%f_Zm = this%Mf%V * pref_Mf_Mz * this%Mz%B/((this%Mf%V* & 
            (pref_Mf_Mz * this%Mz%B + pref_Mf_S*(this%Sf%B + this%Sp%B + this%Sd%B))) + this%Mf%cmax)
            
        this%Mf%f_Sf = this%Mf%V *pref_Mf_S* this%Sf%B/((this%Mf%V* &
            (pref_Mf_Mz * this%Mz%B + pref_Mf_S*(this%Sf%B + this%Sp%B + this%Sd%B))) + this%Mf%cmax)

        this%Mf%f_Sp = this%Mf%V *pref_Mf_S* this%Sp%B/((this%Mf%V* &
            (pref_Mf_Mz * this%Mz%B + pref_Mf_S*(this%Sf%B + this%Sp%B + this%Sd%B))) + this%Mf%cmax)

        this%Mf%f_Sd = this%Mf%V *pref_Mf_S* this%Sd%B/((this%Mf%V* &
            (pref_Mf_Mz * this%Mz%B + pref_Mf_S*(this%Sf%B + this%Sp%B + this%Sd%B))) + this%Mf%cmax) 
                 
        this%Mf%f = this%Mf%f_Zm + this%Mf%f_Sf + this%Mf%f_Sp + this%Mf%f_Sd
        
        ! Medium pelagic:
        this%Mp%f_Zm = this%Mp%V * pref_Mp_Mz * this%Mz%B/((this%Mp%V* (pref_Mp_Mz * this%Mz%B &
            + pref_Mp_S*(this%Sf%B + this%Sp%B + this%Sd%B))) + this%Mp%cmax)

        this%Mp%f_Sf = this%Mp%V *pref_Mp_S* this%Sf%B/((this%Mp%V* (pref_Mp_Mz * this%Mz%B &
            + pref_Mp_S*(this%Sf%B + this%Sp%B + this%Sd%B))) + this%Mp%cmax)

        this%Mp%f_Sp = this%Mp%V *pref_Mp_S* this%Sp%B/((this%Mp%V* (pref_Mp_Mz * this%Mz%B &
            + pref_Mp_S*(this%Sf%B + this%Sp%B + this%Sd%B))) + this%Mp%cmax)

        this%Mp%f_Sd = this%Mp%V *pref_Mp_S* this%Sd%B/((this%Mp%V* (pref_Mp_Mz * this%Mz%B &
            + pref_Mp_S*(this%Sf%B + this%Sp%B + this%Sd%B))) + this%Mp%cmax)
        
        this%Mp%f = this%Mp%f_Zm + this%Mp%f_Sf + this%Mp%f_Sp + this%Mp%f_Sd

        ! Medium Demersals only eat benthos resource: 
        this%Md%f_BE = this%Md%V *pref_Md_BE * this%BE%B/((this%Md%V * pref_Md_BE * this%BE%B) + this%Md%cmax)
        this%Md%f = this%Md%f_BE

        ! Large Demersal: 
        this%Ld%f_Mf = this%Ld%V * pref_Ld_Mf * this%Mf%B /(this%Ld%V * &
            (pref_Ld_Mf * this%Mf%B + pref_Ld_Mp * this%Mp%B + pref_Ld_Md * this%Md%B + pref_Ld_BE * this%BE%B) + this%Ld%cmax)

        this%Ld%f_Mp = this%Ld%V * pref_Ld_Mp * this%Mp%B /(this%Ld%V* &
            (pref_Ld_Mf * this%Mf%B + pref_Ld_Mp * this%Mp%B + pref_Ld_Md * this%Md%B + pref_Ld_BE * this%BE%B) + this%Ld%cmax)

        this%Ld%f_Md = this%Ld%V * pref_Ld_Md * this%Md%B /(this%Ld%V* &
            (pref_Ld_Mf * this%Mf%B + pref_Ld_Mp * this%Mp%B + pref_Ld_Md * this%Md%B + pref_Ld_BE * this%BE%B) + this%Ld%cmax)

        this%Ld%f_BE = this%Ld%V * pref_Ld_BE * this%BE%B /(this%Ld%V* &
            (pref_Ld_Mf * this%Mf%B + pref_Ld_Mp * this%Mp%B + pref_Ld_Md * this%Md%B + pref_Ld_BE * this%BE%B) + this%Ld%cmax)

        this%Ld%f = this%Ld%f_Mf + this%Ld%f_Mp + this%Ld%f_Md + this%Ld%f_BE

        ! Large pelagics: 
        this%Lp%f_Mf = this%Lp%V * pref_Lp_Mf * this%Mf%B / &
            (this%Lp%V* (pref_Lp_Mf * this%Mf%B + pref_Lp_Mp * this%Mp%B) + this%Lp%cmax)

        this%Lp%f_Mp = this%Lp%V * pref_Lp_Mp * this%Mp%B / &
            (this%Lp%V* (pref_Lp_Mf * this%Mf%B + pref_Lp_Mp * this%Mp%B) + this%Lp%cmax)

        this%Lp%f = this%Lp%f_Mf + this%Lp%f_Mp

        !:====================================================================================:!
        !                                Consumption per group                                 !
        !:====================================================================================:!
        
        ! Calcul consumption rate of MesoZoo: -------------------------------------------------
        ! Used for estimation of the fraction of zooplankton biomass consumed: (m-2 d-1)
        this%Sf%cons_Mz = this%Sf%f_Zm * this%Sf%cmax 
        this%Sp%cons_Mz = this%Sp%f_Zm * this%Sp%cmax
        this%Sd%cons_Mz = this%Sd%f_Zm * this%Sd%cmax
        ! Medium
        this%Mf%cons_Mz = this%Mf%f_Zm * this%Mf%cmax
        this%Mp%cons_Mz = this%Mp%f_Zm * this%Mp%cmax

        ! Calcul consumption for each fish group: ----------------------------------------------
        ! Used to calculate the predation mortality on each group: 
        ! Medium forage consumption on fish
        this%Mf%cons_Sf = this%Mf%f_Sf * this%Mf%cmax
        this%Mf%cons_Sp = this%Mf%f_Sp * this%Mf%cmax 
        this%Mf%cons_Sd = this%Mf%f_Sd * this%Mf%cmax
        ! Medium Pelagic consumption on fish
        this%Mp%cons_Sf = this%Mp%f_Sf * this%Mp%cmax
        this%Mp%cons_Sp = this%Mp%f_Sp * this%Mp%cmax 
        this%Mp%cons_Sd = this%Mp%f_Sd * this%Mp%cmax

        ! Medium Demersal consumption on fish
        this%Md%cons_BE = this%Md%f_BE * this%Md%cmax
        ! Large Pelagic:
        this%Lp%cons_Mf = this%Lp%f_Mf * this%Lp%cmax
        this%Lp%cons_Mp = this%Lp%f_Mp * this%Lp%cmax
        ! Large Demersal: 
        this%Ld%cons_Mf = this%Ld%f_Mf * this%Ld%cmax
        this%Ld%cons_Mp = this%Ld%f_Mp * this%Ld%cmax
        this%Ld%cons_Md = this%Ld%f_Md * this%Ld%cmax
        this%Ld%cons_BE = this%Ld%f_BE * this%Ld%cmax

        ! Fraction of zooplankton biomass consumed:
        Cons_Zm = (this%Sf%cons_Mz * this%Sf%B + this%Sp%cons_Mz * this%Sp%B + &
                   this%Sd%cons_Mz * this%Sd%B + this%Mf%cons_Mz * this%Mf%B + &
                   this%Mp%cons_Mz * this%Mp%B)
        this%zf = Cons_Zm/(this%dz + eps)

         ! Calcul fraction of consumption on zooplankton of each group: ----------------------
        if (Cons_Zm > this%dz) then
            frac_Sf = this%Sf%cons_Mz * this%Sf%B / (this%Sf%cons_Mz * this%Sf%B + this%Sp%cons_Mz * this%Sp%B + &
                   this%Sd%cons_Mz * this%Sd%B + this%Mf%cons_Mz * this%Mf%B + &
                   this%Mp%cons_Mz * this%Mp%B)
            frac_Sp = this%Sp%cons_Mz * this%Sp%B / (this%Sf%cons_Mz * this%Sf%B + this%Sp%cons_Mz * this%Sp%B + &
                   this%Sd%cons_Mz * this%Sd%B + this%Mf%cons_Mz * this%Mf%B + &
                   this%Mp%cons_Mz * this%Mp%B)
            frac_Sd = this%Sd%cons_Mz * this%Sd%B / (this%Sf%cons_Mz * this%Sf%B + this%Sp%cons_Mz * this%Sp%B + &
                   this%Sd%cons_Mz * this%Sd%B + this%Mf%cons_Mz * this%Mf%B + &
                   this%Mp%cons_Mz * this%Mp%B)
            frac_Mf = this%Mf%cons_Mz * this%Mf%B / (this%Sf%cons_Mz * this%Sf%B + this%Sp%cons_Mz * this%Sp%B + &
                   this%Sd%cons_Mz * this%Sd%B + this%Mf%cons_Mz * this%Mf%B + &
                   this%Mp%cons_Mz * this%Mp%B)
            frac_Mp = this%Mp%cons_Mz * this%Mp%B / (this%Sf%cons_Mz * this%Sf%B + this%Sp%cons_Mz * this%Sp%B + &
                   this%Sd%cons_Mz * this%Sd%B + this%Mf%cons_Mz * this%Mf%B + &
                   this%Mp%cons_Mz * this%Mp%B)

            ! Actual consumption as the faction of consumption * dz: -------------------------
            ! Divide the biomass consumed by the biomass of the predator to get a per g of predator rate. 
            this%Sf%cons_Mz = frac_Sf * this%dz / this%Sf%B
            this%Sp%cons_Mz = frac_Sp * this%dz / this%Sp%B
            this%Sd%cons_Mz = frac_Sd * this%dz / this%Sd%B
            this%Mf%cons_Mz = frac_Mf * this%dz / this%Mf%B
            this%Mp%cons_Mz = frac_Mp * this%dz / this%Mp%B
        end if  

        ! Total consumption rate with adjusted consumption on zooplankton: ------------------
        this%Sf%cons = this%Sf%cons_Mz
        this%Sp%cons = this%Sp%cons_Mz
        this%Sd%cons = this%Sd%cons_Mz
        this%Mf%cons = this%Mf%cons_Mz + this%Mf%cons_Sf + this%Mf%cons_Sp + this%Mf%cons_Sd 
        this%Mp%cons = this%Mp%cons_Mz + this%Mp%cons_Sf + this%Mp%cons_Sp + this%Mp%cons_Sd

        ! Recalculate feeding level based on new consumption:--------------------------------
        this%Sf%f = this%Sf%cons / this%Sf%cmax
        this%Sp%f = this%Sp%cons / this%Sp%cmax
        this%Sd%f = this%Sd%cons / this%Sd%cmax
        this%Mf%f = this%Mf%cons / this%Mf%cmax
        this%Mp%f = this%Mp%cons / this%Mp%cmax
        
        ! The folowing groups don't feed on zooplankton: ------------------------------------
        this%Md%cons = this%Md%cons_BE
        this%Lp%cons = this%Lp%f * this%Lp%cmax
        this%Ld%cons = this%Ld%f * this%Lp%cmax

    end subroutine Consumption


    subroutine Mortality(this)
        !:======================================================================
        ! Calculate the mortality for fish functional group 
        ! Fishing mortality is assumed constant and nul
        ! mu_p : Predation from fish      [m-2 d-1]
        ! mu_f : Fishing mortality ( = 0) [m-2 d-1]
        ! mu_a : Natural mortality        [m-2 d-1]
        !:======================================================================
        type(Structure_group), intent(inout) :: this

        ! Calcul Predation mortality: -----------------------------------------------
        ! mu_p [m-2 d-1]
        this%Sf%mu_p = (this%Mp%cons_Sf * this%Mp%B + this%Mf%cons_Sf * this%Mf%B) / this%Sf%B
        this%Sp%mu_p = (this%Mp%cons_Sp * this%Mp%B + this%Mf%cons_Sp * this%Mf%B) / this%Sp%B
        this%Sd%mu_p = (this%Mp%cons_Sd * this%Mp%B + this%Mf%cons_Sd * this%Mf%B) / this%Sd%B
        this%Mf%mu_p = (this%Lp%cons_Mf * this%Lp%B + this%Ld%cons_Mf * this%Ld%B) / this%Mf%B
        this%Mp%mu_p = (this%Lp%cons_Mp * this%Lp%B + this%Ld%cons_Mp * this%Ld%B) / this%Mp%B
        this%Md%mu_p = (this%Lp%cons_Md * this%Lp%B + this%Ld%cons_Md * this%Ld%B) / this%Md%B
        this%Lp%mu_p = 0
        this%Ld%mu_p = 0

        ! Calcul Natural mortality:  -----------------------------------------------
        ! Several ways to consider the natural mortality: 
        ! - constant 
        ! - size dependent 
        ! - size and temperature dependent. 
        ! Note that the temperature effect would be and increase of mortality due to 
        ! the effect of temperature on the physiology and not on the increase/decrease of predation resulting
        ! from physiological changes of other groups. 
        !  ------------------------------------------------------------------------
        ! Here I used a constant mortality with temperature and size for comparison with the matlab version
        this%Sf%mu_a = Nat_mrt
        this%Sp%mu_a = Nat_mrt
        this%Sd%mu_a = Nat_mrt
        this%Mf%mu_a = Nat_mrt
        this%Mp%mu_a = Nat_mrt
        this%Md%mu_a = Nat_mrt
        this%Lp%mu_a = Nat_mrt 
        this%Ld%mu_a = Nat_mrt

        ! Calcul Fishing mortality!  ----------------------------------------------
        ! Small fish are not fished
        ! Medium forage are fished at 1 
        ! Large fish are fished at 1 
        !  ------------------------------------------------------------------------
        this%Mf%mu_f = Frate * Aselct
        this%Mp%mu_f = Frate * Jselct * Aselct
        this%Md%mu_f = Frate * Jselct * Aselct
        this%Lp%mu_f = Frate * Aselct
        this%Ld%mu_f = Frate * Aselct


        ! Total mortality:  ----------------------------------------------
        ! Sum of predation, natural, and fishing mortality
        ! ------------------------------------------------------------------------
        this%Sf%mu = this%Sf%mu_p + this%Sf%mu_a + this%Sf%mu_f
        this%Sp%mu = this%Sp%mu_p + this%Sp%mu_a + this%Sp%mu_f
        this%Sd%mu = this%Sd%mu_p + this%Sd%mu_a + this%Sd%mu_f
        this%Mf%mu = this%Mf%mu_p + this%Mf%mu_a + this%Mf%mu_f
        this%Mp%mu = this%Mp%mu_p + this%Mp%mu_a + this%Mp%mu_f
        this%Md%mu = this%Md%mu_p + this%Md%mu_a + this%Md%mu_f
        this%Lp%mu = this%Lp%mu_p + this%Lp%mu_a + this%Lp%mu_f
        this%Ld%mu = this%Ld%mu_p + this%Ld%mu_a + this%Ld%mu_f

    end subroutine Mortality

    subroutine Metabolic_loss(this)
        !:======================================================================
        ! Calculate the Metabolic loss as a function of: 
        ! met        : mass-specific Metabolic loss                      [d-1] 
        ! w          : wet weight                                        [g]  
        ! tcorr_met  : temperature correction                            []
        ! a_mmet     : coefficient for mass-specific metabolic loss      [d-1 g^(b_met)]
        ! b_met      : exponent for mass-specific metabolic loss         []
        !:======================================================================
        type(Structure_group), intent(inout) :: this 
        this%Sf%met = this%Sf%Tcorr_met * a_met * this%Sf%w ** (-b_met) / 365
        this%Sp%met = this%Sp%Tcorr_met * a_met * this%Sp%w ** (-b_met) / 365
        this%Sd%met = this%Sd%Tcorr_met * a_met * this%Sd%w ** (-b_met) / 365
        this%Mf%met = this%Mf%Tcorr_met * a_met * this%Mf%w ** (-b_met) / 365
        this%Mp%met = this%Mp%Tcorr_met * a_met * this%Mp%w ** (-b_met) / 365
        this%Md%met = this%Md%Tcorr_met * a_met * this%Md%w ** (-b_met) / 365
        this%Lp%met = this%Lp%Tcorr_met * a_met * this%Lp%w ** (-b_met) / 365
        this%Ld%met = this%Ld%Tcorr_met * a_met * this%Ld%w ** (-b_met) / 365

    end subroutine Metabolic_loss


    subroutine Available_energy(this)
        !:======================================================================
        ! Calcul Available energy of growth and reproduction 
        ! eps_a  : Assimilation efficiency            []
        ! met    : mass-specific metabolic cost       [d-1]     
        ! Cons   : mass-specific total consumption    [d-1]
        !:======================================================================
        type(Structure_group), intent(inout) :: this
        
        this%Sf%E_A = eps_a * this%Sf%cons - this%Sf%met
        this%Sp%E_A = eps_a * this%Sp%cons - this%Sp%met
        this%Sd%E_A = eps_a * this%Sd%cons - this%Sd%met
        this%Mf%E_A = eps_a * this%Mf%cons - this%Mf%met
        this%Mp%E_A = eps_a * this%Mp%cons - this%Mp%met
        this%Md%E_A = eps_a * this%Md%cons - this%Md%met
        this%Lp%E_A = eps_a * this%Lp%cons - this%Lp%met
        this%Ld%E_A = eps_a * this%Ld%cons - this%Ld%met

        ! The model does not account for storage then E_A has to be positive: 
        this%Sf%E_A = max(zero, this%Sf%E_A) 
        this%Sp%E_A = max(zero, this%Sp%E_A)
        this%Sd%E_A = max(zero, this%Sd%E_A)
        this%Mf%E_A = max(zero, this%Mf%E_A)
        this%Mp%E_A = max(zero, this%Mp%E_A)
        this%Md%E_A = max(zero, this%Md%E_A)
        this%Lp%E_A = max(zero, this%Lp%E_A)
        this%Ld%E_A = max(zero, this%Ld%E_A)

    end subroutine Available_energy

    subroutine Fout(this)
        !:======================================================================
        ! calcul the flux of biomass out of a size class for each fish group  
        !:======================================================================
        type(Structure_group), intent(inout) :: this

        this%Sf%Fout = ((kappa_l * this%Sf%E_A) - this%Sf%mu ) / (1 - (Z_s ** (1 - (this%Sf%mu / (kappa_l * this%Sf%E_A)))) + eps)
        this%Sp%Fout = ((kappa_l * this%Sp%E_A) - this%Sp%mu ) / (1 - (Z_s ** (1 - (this%Sp%mu / (kappa_l * this%Sp%E_A)))) + eps)
        this%Sd%Fout = ((kappa_l * this%Sd%E_A) - this%Sd%mu ) / (1 - (Z_s ** (1 - (this%Sd%mu / (kappa_l * this%Sd%E_A)))) + eps)
        this%Mf%Fout = ((kappa_a * this%Mf%E_A) - this%Mf%mu ) / (1 - (Z_m ** (1 - (this%Mf%mu / (kappa_a * this%Mf%E_A)))) + eps)
        this%Mp%Fout = ((kappa_j * this%Mp%E_A) - this%Mp%mu ) / (1 - (Z_m ** (1 - (this%Mp%mu / (kappa_j * this%Mp%E_A)))) + eps)
        this%Md%Fout = ((kappa_j * this%Md%E_A) - this%Md%mu ) / (1 - (Z_m ** (1 - (this%Md%mu / (kappa_j * this%Md%E_A)))) + eps)
        this%Lp%Fout = ((kappa_a * this%Lp%E_A) - this%Lp%mu ) / (1 - (Z_l ** (1 - (this%Lp%mu / (kappa_a * this%Lp%E_A)))) + eps)
        this%Ld%Fout = ((kappa_a * this%Ld%E_A) - this%Ld%mu ) / (1 - (Z_l ** (1 - (this%Ld%mu / (kappa_a * this%Ld%E_A)))) + eps)

        ! If Fout is higher than E_a take E_a, and 0 is negative: 
        this%Sf%Fout = max(min(this%Sf%Fout, this%Sf%E_A), zero)
        this%Sp%Fout = max(min(this%Sp%Fout, this%Sp%E_A), zero)
        this%Sd%Fout = max(min(this%Sd%Fout, this%Sd%E_A), zero)
        this%Mf%Fout = max(min(this%Mf%Fout, this%Mf%E_A), zero)
        this%Mp%Fout = max(min(this%Mp%Fout, this%Mp%E_A), zero)
        this%Md%Fout = max(min(this%Md%Fout, this%Md%E_A), zero)
        this%Lp%Fout = max(min(this%Lp%Fout, this%Lp%E_A), zero)
        this%Ld%Fout = max(min(this%Ld%Fout, this%Ld%E_A), zero)

    end subroutine Fout

    subroutine Reproduction(this)
        !:======================================================================
        ! Calcul the reproductive flux of biomass 
        ! Repro   : rate (of biomass) invested in reproduction after reproduction loss [m-2 d-1]
        ! eps_R   : Reproduction efficiency 
        ! We DO NOT assum that the biomass that is going out of the last size class (Adult)
        ! is converted to reproduction to account for a fraction of individual dying after 
        ! reproduction. 
        !:======================================================================

        type(Structure_group), intent(inout) :: this

        ! Only Medium forage, large pelagic and demersal reproduce: 
        this%Mf%Repro = (1.0 - kappa_a) * this%Mf%E_A + this%Mf%Fout
        this%Lp%Repro = (1.0 - kappa_a) * this%Lp%E_A + this%Lp%Fout
        this%Ld%Repro = (1.0 - kappa_a) * this%Ld%E_A + this%Ld%Fout

        ! Fout for Adult are set up to 0: (sub_rep function in matlab)
        this%Mf%Fout = 0 
        this%Lp%Fout = 0
        this%Ld%Fout = 0

        ! ! Calculate the recruitment (g/m2/d) for each group
        ! this%Mf%Rec = this%Mf%Repro * this%Mf%B
        ! this%Lp%Rec = this%Lp%Repro * this%Lp%B
        ! this%Ld%Rec = this%Ld%Repro * this%Ld%B

    end subroutine Reproduction


    subroutine Benthic_chemostat(this)
        !:======================================================================
        ! Calcul the Benthic biomass from detritus flux to benthic 
        ! Classic logistic growth rate
        ! The calculation has to be done after the derivative have been calculated 
        ! for each fish group ! 
        !:======================================================================
        ! This%BE%B          : Benthic biomass 
        ! Bent_eff =  0.075  :  Benthic Efficiency from detritus to benthic biomass
        ! CC = 80            : Carring Capacity for benthic chemostat
       !:======================================================================
        type(Structure_group), intent(inout) :: this 
        real(dp) :: r       ! benthic growth rate ((g/m2/d) / (g/m2))
        real(dp) :: pred    ! predation from demersals (g/m2/d)

        pred = this%Md%cons_BE * this%Md%B + this%Ld%cons_BE * this%Ld%B
        r = Bent_eff * this%det / this%BE%B 
        this%BE%B = this%BE%B + r * this%BE%B * (1 - this%BE%B/CC) - pred 
        
    end subroutine Benthic_chemostat
    
end module Physiology

        ! this%Sf%
        ! this%Sp%
        ! this%Sd%
        ! this%Mf%
        ! this%Mp%
        ! this%Md%
        ! this%Lp%
        ! this%Ld%

