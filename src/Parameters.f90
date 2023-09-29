
module Parameters

    implicit none 

    ! input files: ----------------------------------------------------
    character(LEN=280), parameter :: &
    
    ! To use in UCAR -----------------------------------------------------------------
    ! dir_Tb = "/glade/campaign/cesm/development/bgcwg/projects/CESM2-OMIP2-like-4p2z-run/g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch/ocn/proc/tseries/day_1/g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch.pop.h.ecosys.nday1.TEMP_BOTTOM_2.19580101-20211231.nc", &
    ! dir_Tp = "/glade/campaign/cesm/development/bgcwg/projects/CESM2-OMIP2-like-4p2z-run/g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch/ocn/proc/tseries/day_1/g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch.pop.h.ecosys.nday1.TEMP_mean_150m.19580101-20211231.nc", &
    ! dir_zf = "/glade/campaign/cesm/development/bgcwg/projects/CESM2-OMIP2-like-4p2z-run/g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch/ocn/proc/tseries/day_1/g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch.pop.h.ecosys.nday1.mesozooC_zint_100m.19580101-20211231.nc", &
    ! dir_dz = "/glade/campaign/cesm/development/bgcwg/projects/CESM2-OMIP2-like-4p2z-run/g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch/ocn/proc/tseries/day_1/g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch.pop.h.ecosys.nday1.mesozoo_loss_zint_150m.19580101-20211231.nc", &
    ! dir_det = "/glade/campaign/cesm/development/bgcwg/projects/CESM2-OMIP2-like-4p2z-run/g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch/ocn/proc/tseries/day_1/g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch.pop.h.ecosys.nday1.pocToFloor_2.19580101-20211231.nc"

    ! Last FEISTY tunning data -------------------------------------------------------
    dir_Tb = "/project/rdenechere/TunningFEISTY/TL319_g17.4p2z/&
    g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch&
    .pop.h.ecosys.nday1.TEMP_mean_150m.19580101-20211231.nc", &
    dir_Tp = "/project/rdenechere/TunningFEISTY/TL319_g17.4p2z/& 
    g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch.&
    pop.h.ecosys.nday1.TEMP_BOTTOM_2.19580101-20211231.nc", &
    dir_zf = "/project/rdenechere/TunningFEISTY/TL319_g17.4p2z/&
    g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch.&
    pop.h.ecosys.nday1.mesozooC_zint_150m.19580101-20211231.nc", &
    dir_dz = "/project/rdenechere/TunningFEISTY/TL319_g17.4p2z/&
    g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch.&
    pop.h.ecosys.nday1.mesozoo_loss_zint_150m.19580101-20211231.nc", &
    dir_det = "/project/rdenechere/TunningFEISTY/TL319_g17.4p2z/&
    g.e22.GOMIPECOIAF_JRA-1p4-2018.TL319_g17.4p2z.001branch.&
    pop.h.ecosys.nday1.pocToFloor_2.19580101-20211231.nc"

    ! 2D data from last FEISTY tunning: ----------------------------------------------
    ! dir_Tb = "/project/rdenechere/TunningFEISTY/TL319_g17.4p2z/&
    ! 2D_data/TEMP_BOTTOM_2_2D.nc", &
    ! dir_Tp = "/project/rdenechere/TunningFEISTY/TL319_g17.4p2z/& 
    ! 2D_data/TEMP_mean_150m_2D.nc", &
    ! dir_zf = "/project/rdenechere/TunningFEISTY/TL319_g17.4p2z/&
    ! 2D_data/mesozooC_zint_150m_2D.nc", &
    ! dir_dz = "/project/rdenechere/TunningFEISTY/TL319_g17.4p2z/&
    ! 2D_data/mesozoo_loss_zint_150m_2D.nc", &
    ! dir_det = "/project/rdenechere/TunningFEISTY/TL319_g17.4p2z/&
    ! 2D_data/pocToFloor_2_2D.nc"
    
    ! General parameters: ---------------------------------------------
    integer, parameter  :: dp = kind(0.d0)   ! double precision
    real(dp), parameter :: zero = 0.0
    real(dp), parameter :: eps = 1d-200     ! Small number for divisions 
    

    ! Environemental data for test: -----------------------------------
    ! real(dp), parameter :: DataTp = -1.756200, DataTb = -1.908700
    ! real(dp), parameter :: Datadz = 0.002800, Datadet = 0.340100 
    ! real(dp), parameter :: DataZM = 1.377700

    ! Groupe information: ---------------------------------------------
    integer, parameter :: nFishGroup = 8                      ! Number of fish functional group
    integer, parameter :: nResource = 1                       ! Benthic resource  
    integer, parameter :: nDeriv = nFishGroup +  nResource    ! Number of group for witch the derivative is calculated
    real(dp), parameter :: Delta_t = 1.0                      ! Time step [d]

    ! Parameters physiology: ------------------------------------------
    real(dp), parameter :: ke = 0.063              ! [°c-1]                Temperature correction for cmax and encounter
    real(dp), parameter :: kmet = 0.0855           ! [°c-1]                Temperature correction for Metabolic cost cost
    real(dp), parameter :: gamma = 70.0            ! []                    Coeff for mass-specific Encounter rate             
    real(dp), parameter :: b_enc = 0.2             ! [m2 g^(b_enc−1) d−1]  Exponent for mass-specific Encounter rate 
    real(dp), parameter :: h = 20.0                ! [d g^(b_cmax)]        Coeff for Cmax 
    real(dp), parameter :: b_cmax = 0.25           ! []                    Exponent for Cmax 
    real(dp), parameter :: a_met = 0.2*h           ! [d-1 g^(b_met)]       Coeff for Metabolic loss 
    real(dp), parameter :: b_met = 0.175           ! []                    Exponent for Metabolic cost 
    real(dp), parameter :: eps_a =  0.7            ! []                    Assimilation efficiency 
    real(dp), parameter :: Nat_mrt = 0.1/365;      ! [m2 d-1]              Natural mortality coeffient 
    ! Fishing : 
    real(dp), parameter :: Frate = 0.3/365         ! [d-1]                 Fishing intensity 
    real(dp), parameter :: Jselct = 0.1            ! []                    Fishing Selectivity of juveniles  
    real(dp), parameter :: Aselct = 1.0            ! []                    Fishing Selectivity of adult 
    ! Param for Size-class growth rate: 
    real(dp), parameter :: Z_s = 0.001/0.5;        ! Small fish Ratio of upper and lower body size boundary 
    real(dp), parameter :: Z_m = 0.5/250;          ! Medium fish Ratio of upper and lower body size boundary 
    real(dp), parameter :: Z_l = 250.0/125000;     ! Large fish Ratio of upper and lower body size boundary 
    real(dp), parameter :: kappa_l = 1             ! Larvale Fraction of energy available (E_a) invested in growth 
    real(dp), parameter :: kappa_j = 1             ! Juvenile Fraction of energy available (E_a) invested in growth 
    real(dp), parameter :: kappa_a = 0.5           ! Adult Fraction of energy available (E_a) invested in growth 
    real(dp), parameter :: eps_R = 0.01            ! Reproduction efficiency: account for energy spend in reprodutive organe, aditional foraging activities, cost of migration, and death from egg release to hatchement. 
    ! Benthic chemostat
    real(dp), parameter :: Bent_eff =  0.075       ! Benthic Efficiency from detritus to benthic biomass
    real(dp), parameter :: CC = 80                 ! Carring Capacity for benthic chemostat

    ! Parameters feeding preferences: ---------------------------------
    real(dp), parameter :: D = 0.75                     ! Demersal feeding in pelagic reduction
    real(dp), parameter :: A = 0.5                      ! Adult predation reduction
    
    real(dp), parameter :: pref_Mz = 0.9                ! Preference for one mesozooplankton group
    ! Medium Forage 
    real(dp), parameter :: pref_Mf_Mz = 0.5 * pref_Mz   ! Preference for Mesozooplankton   
    real(dp), parameter :: pref_Mf_S = 1.0              ! Preference for small fish
    ! Medium pelagic 
    real(dp), parameter :: pref_Mp_Mz = 0.5 * pref_Mz   ! Preference for Mesozooplankton
    real(dp), parameter :: pref_Mp_S = 1.0              ! Preference for small fish
    ! Medium Demersal 
    real(dp), parameter :: pref_Md_BE = 1.0             ! Preference for Benthos
    ! Large Pelagic
    real(dp), parameter :: pref_Lp_Mf = 1.0 * A         ! Preference for Medium forage
    real(dp), parameter :: pref_Lp_Mp = 1.0 
    ! Large Demersal
    real(dp), parameter :: pref_Ld_Mf = D * A           ! Preference for Medium forage
    real(dp), parameter :: pref_Ld_Mp = D               ! Preference for Medium pelagics
    real(dp), parameter :: pref_Ld_Md = 1.0             ! Preference for Medium Demersal
    real(dp), parameter :: pref_Ld_BE = 1.0             ! Preference for Benthos

end module Parameters