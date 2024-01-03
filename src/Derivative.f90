module Derivative 

    use Parameters
    use Structure
    use physiology

    implicit none
    
    contains

    subroutine CalcBiomass(this)
    !:============================================= 
    ! Calculate the biomass after one time step 
    ! considering the environemental conditions 
    !:============================================= 
        type(Structure_group) :: this
        call Calc_Q10(this)             ! Physiological adjustment to temperature  
        call Consumption(this)          ! 
        call Mortality(this)
        call Metabolic_loss(this)
        call Available_energy(this)
        call Fout(this)
    
    ! ! Element of reproduction Mf
    ! print*, "repro with Esp_R option 1          ", eps_R * ((1.0 - kappa_a) * this%Mf%E_A + this%Mf%Fout)
    ! print*, "repro with Esp_R option 2          ", eps_R * ((1.0 - kappa_a) * this%Mf%E_A) + this%Mf%Fout
    ! print*, "eps_R                              ", eps_R
    ! print*, "kappa_a                            ", kappa_a
    ! print*, "E_a                                ", this%Mf%E_A
    ! print*, "Fout                               ", this%Mf%Fout

       call Reproduction(this)
    ! ----------------------------------------------------
    ! test physioloical calc
    ! ----------------------------------------------------
    ! print*, "Temperature Pel       ", this%Tp
    ! print*, "Temperature bot       ", this%Tb
    ! print*, "Sf Biomass Zoo        ", this%Mz%B
    ! print*, "Sf Tcorr_e            ", this%Sf%Tcorr_e
    ! print*, "Sf Tcorr_met          ", this%Sf%Tcorr_met
    ! print*, "Md Tcorr_e            ", this%Md%Tcorr_e
    ! print*, "Md Tcorr_met          ", this%Md%Tcorr_met
    ! print*, "Sf Clearance rate Sf  ", this%Sf%V
    ! print*, "Sf Cmax Sf            ", this%Sf%cmax
    ! print*, "Sf feeding level Sf   ", this%Sf%f
    ! print*, "Sf Total consumption  ", this%Sf%cons 
    ! print*, "Sf consumption Mz     ", this%Sf%cons_Mz 
    ! print*, "Sf Total mort         ", this%Sf%mu
    ! print*, "Sf Predation mort     ", this%Sf%mu_p
    ! print*, "Sf Natur mort         ", this%Sf%mu_a
    ! print*, "Sf Fishng mort        ", this%Sf%mu_f
    ! print*, "Sf Met loss           ", this%Sf%met
    ! print*, "Sf Available energy   ", this%Sf%E_A
    ! print*, "Sf Fout               ", this%Sf%Fout 
    ! print*, "Sf Repro flux         ", this%Sf%Repro 
    ! print*, "BE biomass            ", this%BE%B
    ! ----------------------------------------------------
    ! print*, "Mf Clearance rate Sf  ", this%Mf%V
    ! print*, "Mf Cmax               ", this%Mf%cmax
    ! print*, "Mf feeding level      ", this%Mf%f
    ! print*, "Consumption Mp to Sf  ", this%Mp%cons_Sf
    ! print*, "Consumption Mf to Sf  ", this%Mf%cons_Sf
    ! print*, "feeding level Mf to Zm", this%Mf%f_Zm
    ! print*, "feeding level Mf to Sf", this%Mf%f_Sf
    ! print*, "feeding level Mf to Sp", this%Mf%f_Sp
    ! print*, "feeding level Mf to Sd", this%Mf%f_Sd
    ! print*, "Encounter Mf to Zm    ", this%Mf%V * pref_Mf_Mz * this%Mz%B
    ! print*, "Encounter Mf to Sf    ", this%Mf%V *pref_Mf_S* this%Sf%B
    ! print*, "Encounter Mf to Sp    ", this%Mf%V *pref_Mf_S* this%Sp%B
    ! print*, "Encounter Mf to Sd    ", this%Mf%V *pref_Mf_S* this%Sd%B
    ! print*, "Pref Mf to Zm         ", pref_Mf_Mz 
    ! print*, "Pref Mf to S          ", pref_Mf_S
    ! print*, "Zooplankton biomass   ", this%Mz%B
    ! print*, "Sf biomass            ", this%Sf%B
    ! ----------------------------------------------------
    ! print*, "Frac Zoo lost         ", this%zf
    ! print*, "Large Dem Cons        ", this%Ld%cons
    ! ----------------------------------------------------
    ! Element of the derivative: Mf
    ! print*, "dMf                   ", this%Sf%Fout * this%Sf%B + (this%Mf%E_A - this%Mf%Repro - this%Mf%mu) * this%Mf%B
    ! print*, "Md E_available        ", this%Md%E_A
    ! print*, "Md consumption        ", this%Md%cons
    ! print*, "Md Clearance rate     ", this%Md%V
    ! print*, "Md Encounter rate     ", this%Md%V *pref_Md_BE * this%BE%B
    ! print*, "Md Cmax               ", this%Md%cmax
    ! print*, "Md metabolism         ", this%Md%met
    ! print*, "Md feeding lvl        ", this%Md%f_BE
    ! print*, "Md feeding lvl 2      ",this%Md%V *pref_Md_BE * this%BE%B/((this%Md%V * pref_Md_BE * this%BE%B) + this%Md%cmax)
    ! print*, "Biomass Bent          ", this%BE%B
    ! print*, "MF mortality          ", this%Md%mu 
    ! print*, "MF pred mort          ", this%Md%mu_p
    ! print*, "MF Nat mort           ", this%Md%mu_a
    ! print*, "MF Fish mort          ", this%Md%mu_f
    ! print*, "Sf_Fout               ", this%Sd%Fout
    ! print*, "Sf_Bio                ", this%Md%B
    ! print*, "Mf Repro              ", this%Md%Repro
    ! print*, "Fout  2               ", this%Md%Fout
    ! print*, "Pred Lp to Mf         ", this%Lp%cons_Md
    ! print*, "Pred Ld to Mf         ", this%Ld%cons_Md 
    ! ! ----------------------------------------------------
        call Euler(this)
        call Biomass_check(this)
    ! ! Print biomass out 
    ! print*, 'Sf Bio out  ', this%Sf%B
    ! print*, 'Sp Bio out  ', this%Sp%B
    ! print*, 'Sd Bio out  ', this%Sd%B
    ! print*, 'Mf Bio out  ', this%Mf%B
    ! print*, 'Mp Bio out  ', this%Mp%B
    ! print*, 'Md Bio out  ', this%Md%B
    ! print*, 'Lp Bio out  ', this%Lp%B
    ! print*, 'Ld Bio out  ', this%Ld%B
    ! stop

    end subroutine CalcBiomass


    subroutine Euler(this)
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
        type(Structure_group), intent(inout) :: this
        
        real(dp) :: dSf = 0
        real(dp) :: dSp = 0
        real(dp) :: dSd = 0
        real(dp) :: dMf = 0
        real(dp) :: dMp = 0
        real(dp) :: dMd = 0
        real(dp) :: dLp = 0
        real(dp) :: dLd = 0

        ! Calcul new Benthic biomass 
        call Benthic_chemostat(this)

        ! Calcul derivative for each group : --------------------
        ! Small size (no loss from reproduction)
        dSf = eps_R * this%Mf%Repro * this%Mf%B + (this%Sf%E_A - this%Sf%Fout - this%Sf%mu) * this%Sf%B
        dSp = eps_R * this%Lp%Repro * this%Lp%B + (this%Sp%E_A - this%Sp%Fout - this%Sp%mu) * this%Sp%B
        dSd = eps_R * this%Ld%Repro * this%Ld%B + (this%Sd%E_A - this%Sd%Fout - this%Sd%mu) * this%Sd%B  
        
        ! Medium size (reproduction loss for Mf)
        dMf = this%Sf%Fout * this%Sf%B + (this%Mf%E_A - this%Mf%Repro - this%Mf%mu) * this%Mf%B 
        dMp = this%Sp%Fout * this%Sp%B + (this%Mp%E_A - this%Mp%Fout  - this%Mp%mu) * this%Mp%B 
        dMd = this%Sd%Fout * this%Sd%B + (this%Md%E_A - this%Md%Fout  - this%Md%mu) * this%Md%B 
        
        ! Large fish (reproduction Fout = 0) 
        dLp = this%Mp%Fout * this%Mp%B + (this%Lp%E_A - this%Lp%Repro - this%Lp%mu) * this%Lp%B
        dLd = this%Md%Fout * this%Md%B + (this%Ld%E_A - this%Ld%Repro - this%Ld%mu) * this%Ld%B 

        ! print *, "---------------------------------------------------------"
        ! print *, "                 Derivative Md                       "
        ! print*, 'Md Fout                ',this%Sd%Fout 
        ! print*, 'Sd Biomass             ', this%Sd%B 
        ! print*, 'Md Biomass             ', this%Md%B 
        
        ! (this%Md%E_A - this%Md%Fout  - this%Md%mu) * this%Md%B 

        ! New biomass : ------------------------------------------
        ! Euler schem: 
        this%Sf%B = this%Sf%B + Delta_t * dSf
        this%Sp%B = this%Sp%B + Delta_t * dSp
        this%Sd%B = this%Sd%B + Delta_t * dSd
        this%Mf%B = this%Mf%B + Delta_t * dMf
        this%Mp%B = this%Mp%B + Delta_t * dMp
        this%Md%B = this%Md%B + Delta_t * dMd
        this%Lp%B = this%Lp%B + Delta_t * dLp
        this%Ld%B = this%Ld%B + Delta_t * dLd

        ! print *, "---------------------------------------------------------"
        ! print *, "                 Derivative values                       "
        ! print *, "Small forgage         ",  dSf
        ! print *, "Small pelagic         ",  dSp
        ! print *, "Small demerdal        ",  dSd 
        ! print *, "Medium Forage         ",  dMf  
        ! print *, "Medium pelagic        ",  dMp
        ! print *, "Medium demerdal       ",  dMd
        ! print *, "Large pelagic         ",  dLp   
        ! print *, "Large demerdal        ",  dLd
        ! print *, "---------------------------------------------------------"
        ! stop

    end subroutine Euler


    subroutine Biomass_check(this)
        !:====================================================================== 
        ! If the resulting biomass is equal or lower than 0 we give it a positive but 
        ! small value. 
        !:====================================================================== 
        type(Structure_group), intent(inout) :: this
        if (this%BE%B <= zero) then  ! Benthic biomass 
            this%BE%B = eps
        end if 
        if (this%Mz%B <= zero) then  ! Zooplankton Biomass
            this%Mz%B = eps
        end if 
        if (this%Sf%B <= zero) then  ! Small forage 
            this%Sf%B = eps
        end if 
        if (this%Sp%B <= zero) then  ! Small Pelagic
            this%Sp%B = eps
        end if 
        if (this%Sd%B <= zero) then  ! Small Demersal
            this%Sd%B = eps
        end if 
        if (this%Mf%B <= zero) then  ! Medium Forage 
            this%Mf%B = eps
        end if 
        if (this%Mp%B <= zero) then  ! Medium Pelagics 
            this%Mp%B = eps
        end if 
        if (this%Md%B <= zero) then  ! Medium demersal
            this%Md%B = eps
        end if 
        if (this%Lp%B <= zero) then  ! Large pelagic
            this%Lp%B = eps
        end if 
        if (this%Ld%B <= zero) then  ! Large demersal
            this%Ld%B = eps
        end if
    end subroutine Biomass_check


end module