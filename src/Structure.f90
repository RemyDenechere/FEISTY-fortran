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
        type(Structure_Resource) :: Mz, BE, &
                                Sf, Sp, Sd, &
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
    end type Structure_group
    
    type :: Save_structure
        real(dp), dimension(:, :, :), allocatable :: Sf, Sp, Sd, Mf, Mp, Md, Lp, Ld
    end type
        

    contains 
    
    subroutine initPhysiology(this)
        type(Structure_group), intent(inout) :: this 
        
        ! Give initial condition 
        ! Will be loaded from saved pattern (spinup)
        this%Mz%B = 0.001
        this%BE%B = 0.001
        this%Sf%B = 0.001
        this%Sp%B = 0.001
        this%Sd%B = 0.001
        this%Mf%B = 0.001
        this%Mp%B = 0.001
        this%Md%B = 0.001
        this%Lp%B = 0.001
        this%Ld%B = 0.001

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
    
    subroutine init_save_data_3D(this, Nlat, Nlong, Ntime)
        type(Save_structure) :: this
        integer :: Nlat, Nlong, Ntime
        
        allocate(this%Sf(Nlat, Nlong, Ntime))
        allocate(this%Sp(Nlat, Nlong, Ntime))
        allocate(this%Sd(Nlat, Nlong, Ntime))
        allocate(this%Mf(Nlat, Nlong, Ntime))
        allocate(this%Mp(Nlat, Nlong, Ntime))
        allocate(this%Md(Nlat, Nlong, Ntime))
        allocate(this%Lp(Nlat, Nlong, Ntime))
        allocate(this%Ld(Nlat, Nlong, Ntime))
    
    end subroutine init_save_data
    
    subroutine save_data(this, that, ilat, ilong, itime)
        type(Save_structure) :: this
        type(Structure_group) :: that
        integer :: ilat, ilong, itime
        
        this%Sf(ilat, ilong, itime) = that%Sf%B
        this%Sp(ilat, ilong, itime) = that%Sp%B
        this%Sd(ilat, ilong, itime) = that%Sd%B
        this%Mf(ilat, ilong, itime) = that%Mf%B
        this%Mp(ilat, ilong, itime) = that%Mp%B
        this%Md(ilat, ilong, itime) = that%Md%B
        this%Lp(ilat, ilong, itime) = that%Lp%B
        this%Ld(ilat, ilong, itime) = that%Ld%B
    end subroutine save_data


end module Structure