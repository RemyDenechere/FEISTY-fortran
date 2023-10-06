module Derivative 

    use Parameters
    use Structure
    use physiology

    implicit none
     ! Environemental parameters: 
    
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
        call Euler(this)
        call Biomass_check(this)
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
        dSf = this%Mf%Repro * this%Mf%B + (this%Sf%E_A - this%Sf%Fout - this%Sf%mu) * this%Sf%B
        dSp = this%Lp%Repro * this%Lp%B + (this%Sp%E_A - this%Sp%Fout - this%Sp%mu) * this%Sp%B
        dSd = this%Ld%Repro * this%Ld%B + (this%Sd%E_A - this%Sd%Fout - this%Sd%mu) * this%Sd%B  
        
        ! Medium size (reproduction loss for Mf)
        dMf = this%Sf%Fout * this%Sf%B + (this%Mf%E_A - this%Mf%Repro - this%Mf%mu) * this%Mf%B 
        dMp = this%Sp%Fout * this%Sp%B + (this%Mp%E_A - this%Mp%Fout  - this%Mp%mu) * this%Mp%B 
        dMd = this%Sd%Fout * this%Sd%B + (this%Md%E_A - this%Md%Fout  - this%Md%mu) * this%Md%B 
        
        ! Large fish (reproduction Fout = 0) 
        dLp = this%Mp%Fout * this%Mp%B + (this%Lp%E_A - this%Lp%Repro - this%Lp%mu) * this%Lp%B
        dLd = this%Md%Fout * this%Md%B + (this%Ld%E_A - this%Ld%Repro - this%Ld%mu) * this%Ld%B 

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