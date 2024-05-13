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
        call Reproduction(this)
    
        if (diagnostic) then 
            !----------------------------------------------------
            !test physioloical calc
            !----------------------------------------------------
            print*, '----------------------------------------------------'
            print*, "Temperature           ", this%Temp
            print*, "Detritus flux         ", this%det
            print*, "Sf Biomass Zoo m      ", this%Mz%B
            print*, "Sf Biomass Zoo l      ", this%Lz%B
            print*, "Sf MORT Zoo m         ", this%dzm
            print*, "Sf MORT Zoo l         ", this%dzl    


            print*, "Sf Tcorr_e            ", this%Sf%Tcorr_e
            print*, "Sf Tcorr_met          ", this%Sf%Tcorr_met
            print*, "Md Tcorr_e            ", this%Md%Tcorr_e
            print*, "Md Tcorr_met          ", this%Md%Tcorr_met
            print*, "Sf Clearance rate Sf  ", this%Sf%V
            print*, "Sf Cmax Sf            ", this%Sf%cmax
            print*, "Sf feeding level Sf   ", this%Sf%f
            print*, "Sf Total consumption  ", this%Sf%cons 
            print*, "Sf consumption Mz     ", this%Sf%cons_Mz 
            print*, "Sf Total mort         ", this%Sf%mu
            print*, "Sf Predation mort     ", this%Sf%mu_p
            print*, "Sf Natur mort         ", this%Sf%mu_a
            print*, "Sf Fishng mort        ", this%Sf%mu_f
            print*, "Sf Met loss           ", this%Sf%met
            print*, "Sf Available energy   ", this%Sf%E_A
            print*, "Sf Fout               ", this%Sf%Fout 
            print*, "Sf Recruitment        ", this%Mf%Repro
            print*, "Sf Repro flux         ", this%Sf%Repro 
            print*, "Sf Recruitment flux   ", this%Mf%Repro * eps_R
            print*, "Mf Repro flux         ", this%Mf%Repro
            print *, '----------------------------------------------------'
            print*, "BE biomass            ", this%BE%B

            print *, '----------------------------------------------------'
            print *, 'Element of the derivative: MF' 
            print*, "Mf Clearance rate Sf  ", this%Mf%V
            print*, "Mf Cmax               ", this%Mf%cmax
            print*, "Mf feeding level      ", this%Mf%f
            print*, "Mf Total mort         ", this%Mf%mu
            print*, "Mf Predation mort     ", this%Mf%mu_p
            print*, "Mf Natur mort         ", this%Mf%mu_a
            print*, "Mf Fishng mort        ", this%Mf%mu_f
            print*, "Mf Met loss           ", this%Mf%met
            print*, "Mf Available energy   ", this%Mf%E_A
            print*, "Mf Fout               ", this%Mf%Fout 
            print*, "Mf Reproduction       ", this%Mf%Repro
            print*, "Mf biomass            ", this%Sf%B
            print *, '----------------------------------------------------'
            print *, 'MF consumption ' 
            print*, "Consumption Mp to Sf  ", this%Mp%cons_Sf
            print*, "Consumption Mf to Sf  ", this%Mf%cons_Sf
            print*, "feeding level Mf to Zm", this%Mf%f_Zm
            print*, "feeding level Mf to Sf", this%Mf%f_Sf
            print*, "feeding level Mf to Sp", this%Mf%f_Sp
            print*, "feeding level Mf to Sd", this%Mf%f_Sd
            print*, "Encounter Mf to Zm    ", this%Mf%V * pref_Mf_Mz * this%Mz%B
            print*, "Encounter Mf to Sf    ", this%Mf%V *pref_Mf_S* this%Sf%B
            print*, "Encounter Mf to Sp    ", this%Mf%V *pref_Mf_S* this%Sp%B
            print*, "Encounter Mf to Sd    ", this%Mf%V *pref_Mf_S* this%Sd%B
            print*, "Pref Mf to Zm         ", pref_Mf_Mz 
            print*, "Pref Mf to S          ", pref_Mf_S
            print*, "Zooplankton biomass   ", this%Mz%B
            print *, '----------------------------------------------------'
            print *, 'MF predators ' 
            print*, "Consumption Lp to Mf  ", this%Lp%cons_Mf
            print*, "Consumption Ld to Mf  ", this%Ld%cons_Mf

            print *, '----------------------------------------------------'
            print*, "Frac Zoo lost M       ", this%Zcons_VS_dZm
            print*, "Frac Zoo lost L       ", this%Zcons_VS_dZl
            print*, "Large Dem Cons        ", this%Ld%cons
            print *, '----------------------------------------------------'
            print *, 'Element of the derivative: MD' 
            print*, "dMf                   ", this%Sf%Fout * this%Sf%B + (this%Mf%E_A - this%Mf%Repro - this%Mf%mu) * this%Mf%B
            print*, "Md E_available        ", this%Md%E_A
            print*, "Md consumption        ", this%Md%cons
            print*, "Md Clearance rate     ", this%Md%V
            print*, "Md Encounter rate     ", this%Md%V *pref_Md_BE * this%BE%B
            print*, "Md Cmax               ", this%Md%cmax
            print*, "Md metabolism         ", this%Md%met
            print*, "Md feeding lvl        ", this%Md%f_BE
            print*, "Md feeding lvl 2  ", this%Md%V *pref_Md_BE * this%BE%B/((this%Md%V * pref_Md_BE * this%BE%B) + this%Md%cmax)
            print*, "Biomass Bent          ", this%BE%B
            print*, "Md mortality          ", this%Md%mu 
            print*, "Md pred mort          ", this%Md%mu_p
            print*, "Md Nat mort           ", this%Md%mu_a
            print*, "Md Fish mort          ", this%Md%mu_f
            print*, "Sf_Fout               ", this%Sd%Fout
            print*, "Md recr               ", this%Sd%Fout * this%Sd%B
            print*, "Sf_Bio                ", this%Md%B
            print*, "Md Repro              ", this%Md%Repro
            print*, "Md Fout               ", this%Md%Fout
            print*, "Md Bio                ", this%Md%B

            print *, '----------------------------------------------------'
            print *, 'cmax and clearance rate for large predators' 
            print*, "Lp Encounter rate     ", this%Lp%V
            print*, "Lp Cmax               ", this%Lp%cmax
        end if 
 
    ! ----------------------------------------------------
        call Euler(this)

        ! print *, '----------------------------------------------------'
        ! print *, 'Element of the derivative: LD' 
        ! print*, "Ld E_available        ", this%Ld%E_A
        ! print*, "Ld consumption        ", this%Ld%cons
        ! print*, "Ld Clearance rate     ", this%Ld%V
        ! print*, "Ld Encounter rate     ", this%Ld%V *pref_Ld_BE * this%BE%B
        ! print*, "Ld Cmax               ", this%Ld%cmax
        ! print*, "Ld metabolism         ", this%Ld%met
        ! print*, "Ld feeding lvl        ", this%Ld%f_BE
        ! print*, "Ld feeding lvl 2      ", this%Ld%V *pref_Ld_BE * this%BE%B/((this%Ld%V * pref_Ld_BE * this%BE%B) + this%Ld%cmax)
        ! print*, "Biomass Bent          ", this%BE%B
        ! print*, "Ld mortality          ", this%Ld%mu 
        ! print*, "Ld pred mort          ", this%Ld%mu_p
        ! print*, "Ld Nat mort           ", this%Ld%mu_a
        ! print*, "Ld Fish mort          ", this%Ld%mu_f
        ! print*, "Md_Fout               ", this%Md%Fout
        ! print*, "Ld recr               ", this%Md%Fout * this%Md%B
        ! print*, "Sf_Bio                ", this%Ld%B
        ! print*, "Ld Repro              ", this%Ld%Repro
        ! print*, "Ld Fout               ", this%Ld%Fout
        ! print*, "Ld Bio                ", this%Ld%B
        ! print*, "Benthic biomass       ", this%BE%B
 
        !  print*, "Pred Ld to Md         ", this%Ld%cons_Md 
        !  print*, "Pred Ld to Mp         ", this%Ld%cons_Mp
        !  print*, "Pred Ld to Mf         ", this%Ld%cons_Mf
        !  print*, "Pred Ld to Be         ", this%Ld%cons_BE

        !  stop

        call Biomass_check(this)
    
        if (diagnostic) then 
            stop
        end if
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
        
        real(dp) :: dSf = 0.0
        real(dp) :: dSp = 0.0
        real(dp) :: dSd = 0.0
        real(dp) :: dMf = 0.0
        real(dp) :: dMp = 0.0
        real(dp) :: dMd = 0.0
        real(dp) :: dLp = 0.0
        real(dp) :: dLd = 0.0

        if (diagnostic) then 
            print *, "---------------------------------------------------------"
            print *, "                   old biomass "
            print *, this%Sf%B
            print *, this%Sp%B
            print *, this%Sd%B
            print *, this%Mf%B
            print *, this%Mp%B
            print *, this%Md%B
            print *, this%Lp%B
            print *, this%Ld%B
        end if 

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

        
        if (diagnostic) then 
            print *, "---------------------------------------------------------"
            print *, "                 Derivative values                       "
            print *, "Small forgage         ",  dSf
            print *, "Small pelagic         ",  dSp
            print *, "Small demerdal        ",  dSd 
            print *, "Medium Forage         ",  dMf  
            print *, "Medium pelagic        ",  dMp
            print *, "Medium demerdal       ",  dMd
            print *, "Large pelagic         ",  dLp   
            print *, "Large demerdal        ",  dLd
            print *, "---------------------------------------------------------"
            print *, "Small forgage         ",  Delta_t * dSf
            print *, "Small pelagic         ",  Delta_t * dSp
            print *, "Small demerdal        ",  Delta_t * dSd 
            print *, "Medium Forage         ",  Delta_t * dMf  
            print *, "Medium pelagic        ",  Delta_t * dMp
            print *, "Medium demerdal       ",  Delta_t * dMd
            print *, "Large pelagic         ",  Delta_t * dLp   
            print *, "Large demerdal        ",  Delta_t * dLd
            print *, Delta_t
            print *, "---------------------------------------------------------"
            print *, "                   New biomass "
            print *, this%Sf%B
            print *, this%Sp%B
            print *, this%Sd%B
            print *, this%Mf%B
            print *, this%Mp%B
            print *, this%Md%B
            print *, this%Lp%B
            print *, this%Ld%B
        end if 

    end subroutine Euler


    subroutine Biomass_check(this)
        !:====================================================================== 
        ! If the resulting biomass is equal or lower than 0 we give it a positive but 
        ! small value. 
        !:====================================================================== 
        type(Structure_group), intent(inout) :: this

        ! Check for negative values: -----------------------------------------------
        if (this%BE%B <= zero) then  ! Benthic biomass 
            this%BE%B = 1d-5
        end if 
        if (this%Mz%B <= zero) then  ! Zooplankton Biomass
            this%Mz%B = 1d-5
        end if 
        if (this%Sf%B <= zero) then  ! Small forage 
            this%Sf%B = 1d-5
        end if 
        if (this%Sp%B <= zero) then  ! Small Pelagic
            this%Sp%B = 1d-5
        end if 
        if (this%Sd%B <= zero) then  ! Small Demersal
            this%Sd%B = 1d-5
        end if 
        if (this%Mf%B <= zero) then  ! Medium Forage 
            this%Mf%B = 1d-5
        end if 
        if (this%Mp%B <= zero) then  ! Medium Pelagics 
            this%Mp%B = 1d-5
        end if 
        if (this%Md%B <= zero) then  ! Medium demersal
            this%Md%B = 1d-5
        end if 
        if (this%Lp%B <= zero) then  ! Large pelagic
            this%Lp%B = 1d-5
        end if 
        if (this%Ld%B <= zero) then  ! Large demersal
            this%Ld%B = 1d-5
        end if

        ! Check for NA values: ----------------------------------------------------
        if (isnan(this%BE%B)) then  ! Benthic biomass 
            this%BE%B = 1d-5
        end if 
        if (isnan(this%Mz%B)) then  ! Zooplankton Biomass
            this%Mz%B = 1d-5
        end if 
        if (isnan(this%Sf%B)) then  ! Small forage 
            this%Sf%B = 1d-5
        end if 
        if (isnan(this%Sp%B)) then  ! Small Pelagic
            this%Sp%B = 1d-5
        end if 
        if (isnan(this%Sd%B)) then  ! Small Demersal
            this%Sd%B = 1d-5
        end if 
        if (isnan(this%Mf%B)) then  ! Medium Forage 
            this%Mf%B = 1d-5
        end if 
        if (isnan(this%Mp%B)) then  ! Medium Pelagics 
            this%Mp%B = 1d-5
        end if 
        if (isnan(this%Md%B)) then  ! Medium demersal
            this%Md%B = 1d-5
        end if 
        if (isnan(this%Lp%B)) then  ! Large pelagic
            this%Lp%B = 1d-5
        end if 
        if (isnan(this%Ld%B)) then  ! Large demersal
            this%Ld%B = 1d-5
        end if

    end subroutine Biomass_check


end module
