module Parameters

    implicit none 

    ! General parameters: ---------------------------------------------
    integer, parameter  :: dp = kind(0.d0)   ! double precision
    real(dp), parameter :: zero = 0.0        ! Zero
    real(dp), parameter :: eps = 1d-30      ! Small number for divisions 
    integer, parameter  :: YR = 1            ! Number of year in Time series
    integer, parameter  :: Nmonth = YR*12    ! Number of month in Time series
    integer, parameter  :: Year_2_Spinup = 100
    integer, dimension(12), parameter ::  MNTH = (/ 31, 28, 31, 30, 31, 30, &
                                                    31, 31, 30, 31, 30, 31 /) ! Length of month (days)

    ! Environemental data for test: -----------------------------------
    real(dp), parameter :: PI_be_cutoff = 200 ! Benthic-pelagic coupling cutoff (depth, m)
    logical, parameter  :: diagnostic = .false.
    logical, parameter  :: save_diagnostics = .false.
    logical, parameter  :: prod_constrained = .true.
    logical, parameter  :: Spinup_Time_Serie = .true.
    logical, parameter  :: Initial_Condition_generic_FEISTY = .true.
    real(dp), parameter :: conv_m2_to_m3 = 100.0
    

    ! Groupe information: ---------------------------------------------
    integer, parameter :: nFishGroup = 8                     ! Number of fish functional group
    integer, parameter :: nMesoZoo = 2
    integer, parameter :: nBenthos = 1                       ! Benthic resource  
    integer, parameter :: nDeriv = nFishGroup +  nBenthos    ! Number of group for witch the derivative is calculated
    real(dp), parameter :: Delta_t = 1.0                     ! Time step [d]
    real(dp), parameter :: IC = 1d-5                         ! Fish Initial Condition


    ! input files: ----------------------------------------------------
    character(LEN=280), parameter :: root_dir = "/project/rdenechere/COBALT_output/COBALT_offline_forcing_files/"
    character(LEN=280) , parameter :: exp = "COBALT_offline_BATS"

    character(LEN=280), parameter :: &
        dir_Temp = trim(root_dir) // "20040101.ocean_feisty_forcing_offline.nc", &
        dir_zm = trim(root_dir) //   "20040101.ocean_feisty_forcing_offline.nc", &
        dir_dzm = trim(root_dir) //  "20040101.ocean_feisty_forcing_offline.nc", &
        dir_zl = trim(root_dir) //   "20040101.ocean_feisty_forcing_offline.nc", &
        dir_dzl = trim(root_dir) //  "20040101.ocean_feisty_forcing_offline.nc", &
        dir_det = trim(root_dir) //  "20040101.ocean_feisty_forcing_offline_detritus.nc", &
        var_Temp =  "thetao" , &
        var_zm =  "nmdz" , &
        var_dzm =  "jhploss_n_Mdz", &
        var_zl =  "nlgz" , &
        var_dzl =  "jhploss_n_Lgz",& 
        var_det = "Pop_btm"

    ! Input data (Spinup): --------------------------------------------
    character(LEN=280), parameter :: &
        Dir_IniBE = "../output/" // trim(exp) // "_BE_bio_Spinup.nc",&
        Dir_IniSf = "../output/" // trim(exp) // "_Sf_bio_Spinup.nc",&
        Dir_IniSp = "../output/" // trim(exp) // "_Sp_bio_Spinup.nc",&
        Dir_IniSd = "../output/" // trim(exp) // "_Sd_bio_Spinup.nc",&
        Dir_IniMf = "../output/" // trim(exp) // "_Mf_bio_Spinup.nc",&
        Dir_IniMp = "../output/" // trim(exp) // "_Mp_bio_Spinup.nc",&
        Dir_IniMd = "../output/" // trim(exp) // "_Md_bio_Spinup.nc",&
        Dir_IniLp = "../output/" // trim(exp) // "_Lp_bio_Spinup.nc",&
        Dir_IniLd = "../output/" // trim(exp) // "_Ld_bio_Spinup.nc"
    
    ! Input files as array: ------------------------------------------
    character(LEN=280), dimension(nDeriv), parameter :: &
        Dir_IC = [  "../output/" // trim(exp) // "_Sf_bio_Spinup.nc", &
                    "../output/" // trim(exp) // "_Sp_bio_Spinup.nc", &
                    "../output/" // trim(exp) // "_Sd_bio_Spinup.nc", &
                    "../output/" // trim(exp) // "_Mf_bio_Spinup.nc", &
                    "../output/" // trim(exp) // "_Mp_bio_Spinup.nc", &
                    "../output/" // trim(exp) // "_Md_bio_Spinup.nc", &
                    "../output/" // trim(exp) // "_Lp_bio_Spinup.nc", &
                    "../output/" // trim(exp) // "_Ld_bio_Spinup.nc", &
                    "../output/" // trim(exp) // "_BE_bio_Spinup.nc"    ]

    character(LEN=280), parameter :: dir_COBALT_IC = "/project/CEFI-regional-MOM6/&
            &exps/OM4.single_column.COBALT/INPUT/COBALT_2023_10_spinup_2003_subset.nc"
    ! character(LEN=280), parameter :: dir_Diag_nc = "/project/CEFI-regional-MOM6/&
    !         &exps/OM4.single_column.COBALT/INPUT/" // trim(exp) // "_Diag.nc"


    character(len=2), dimension(nDeriv)  :: tracers_name = ["Sf", "Sp", "Sd", "Mf", "Mp", "Md", "Lp", "Ld", "BE"]
    character(len=33), dimension(nDeriv) :: tracers_long_name =["Small forage fish biomass        ", &
                                                                "Small large pelagic fish biomass ", &
                                                                "Small demersal fish biomass      ", &
                                                                "Medium forage fish biomass       ", &
                                                                "Medium large pelagic fish biomass", &
                                                                "Medium demersal fish biomass     ", &
                                                                "Large pelagic fish biomass       ", &
                                                                "Large demersal fish biomass      ", &
                                                                "Benthic invertebrate biomass     "]

    integer, parameter ::   Sf = 1, &  ! -- Fish ID code --
                            Sp = 2, &
                            Sd = 3, &
                            Mf = 4, &
                            Mp = 5, &
                            Md = 6, & 
                            Lp = 7, &
                            Ld = 8, &
                            BE = 9

    integer, parameter ::   Mz = 1, &  ! -- MesoZooplankton ID code --
                            Lz = 2

    ! Parameters physiology: ------------------------------------------
    real(dp), parameter :: ke = 0.0630             ! [°c-1]                Temperature correction for cmax and encounter
    real(dp), parameter :: kmet = 0.08550          ! [°c-1]                Temperature correction for Metabolic cost cost
    real(dp), parameter :: gamma = 70.0 * conv_m2_to_m3 ! []                    Coeff for mass-specific Encounter rate             
    real(dp), parameter :: b_enc = 0.20            ! [m-2 g^(b_enc−1) d−1] Exponent for mass-specific Encounter rate 
    real(dp), parameter :: h = 20.0                ! [d g^(b_cmax)]        Coeff for Cmax 
    real(dp), parameter :: b_cmax = 0.250          ! []                    Exponent for Cmax 
    real(dp), parameter :: a_met = 0.20*h          ! [d-1 g^(b_met)]       Coeff for Metabolic loss 
    real(dp), parameter :: b_met = 0.1750          ! []                    Exponent for Metabolic cost 
    real(dp), parameter :: eps_a =  0.70           ! []                    Assimilation efficiency 
    real(dp), parameter :: Nat_mrt = 0.10/365.0;   ! [m-2 d-1]             Natural mortality coeffient 
    ! Fishing : ---------------------------------------------------------
    real(dp), parameter :: Frate = 0.30/365.0      ! [d-1]                 Fishing intensity 
    real(dp), parameter :: Jselct = 0.10           ! []                    Fishing Selectivity of juveniles  
    real(dp), parameter :: Aselct = 1.0            ! []                    Fishing Selectivity of adult 
    
    ! Param for Size-class growth rate: ----------------------------------
    real(dp), parameter :: Z_s = 0.0010/0.50;      ! Small fish Ratio of upper and lower body size boundary 
    real(dp), parameter :: Z_m = 0.50/250.0;       ! Medium fish Ratio of upper and lower body size boundary 
    real(dp), parameter :: Z_l = 250.0/125000.0;   ! Large fish Ratio of upper and lower body size boundary 
    real(dp), dimension(nFishGroup) :: Z = (/Z_s, Z_s, Z_s, Z_m, Z_m, Z_m, Z_l, Z_l /)
    real(dp), parameter :: kappa_l = 1.0           ! Larval Fraction of energy available (E_a) invested in growth 
    real(dp), parameter :: kappa_j = 1.0           ! Juvenile Fraction of energy available (E_a) invested in growth 
    real(dp), parameter :: kappa_a = 0.50          ! Adult Fraction of energy available (E_a) invested in growth 
    real(dp), dimension(nFishGroup) :: kappa = (/kappa_l, kappa_l, kappa_l,  kappa_a, kappa_j, kappa_j, kappa_a, kappa_a/)
    real(dp), parameter :: eps_R = 0.010           ! Reproduction efficiency: account for energy spend in reprodutive organe, aditional foraging activities, cost of migration, and death from egg release to hatchement. 
    ! Benthic chemostat
    real(dp), parameter :: Bent_eff =  0.0750      ! Benthic Efficiency from detritus to benthic biomass
    real(dp), parameter :: CC = 80.0               ! Carring Capacity for benthic chemostat

    ! Parameters feeding preferences: ---------------------------------
    real(dp), parameter :: Sm = 0.25                     ! Medium size feeding on Medium Zoo
    real(dp), parameter :: D  = 0.750                    ! Demersal feeding in pelagic reduction
    real(dp), parameter :: A  = 0.50                     ! Adult predation reduction
    
    real(dp), parameter :: pref_Mz = 1.0                ! Preference Small fish for medium mesozooplankton group
    ! Medium Forage 
    real(dp), parameter :: pref_Mf_Mz = Sm              ! Preference for Medium Mesozooplankton   
    real(dp), parameter :: pref_Mf_Lz = 1.0             ! Preference for Large Mesozooplankton
    real(dp), parameter :: pref_Mf_S = 1.0              ! Preference for small fish
    ! Medium pelagic 
    real(dp), parameter :: pref_Mp_Mz = Sm              ! Preference for Medium Mesozooplankton
    real(dp), parameter :: pref_Mp_Lz = 1.0             ! Preference for Large Mesozooplankton
    real(dp), parameter :: pref_Mp_S = 1.0              ! Preference for small fish
    ! Medium Demersal  
    real(dp), parameter :: pref_Md_BE = 1.0             ! Preference for Benthos
    ! Large Pelagic
    real(dp), parameter :: pref_Lp_Mf = 1.0 * A         ! Preference for Medium forage
    real(dp), parameter :: pref_Lp_Mp = 1.0 
    ! Large Demersal
    real(dp), parameter :: pref_Ld_Mf = D * A           ! Preference for Medium forage
    real(dp), parameter :: pref_Ld_Mp = D               ! Preference for Medium pelagics
    real(dp), parameter :: pref_Ld_Md =  1.0            ! Preference for Medium Demersal
    real(dp), parameter :: pref_Ld_BE = 1.0/conv_m2_to_m3 ! Preference for Benthos; divide conv_m2_to_m3 to unballance increase gamma 
                                                          ! as predation on demersal does not change unit.

    ! Unit conversion for input data: ---------------------------------------------- 
    ! real(dp), parameter :: convers_zm  = 10.0**(-3 -2)*12.01*9.0, &                  ! zooplankton biomass 
    !                        convers_det = 10.0**(-9 +4)*12.01*9.0*24.0*3600.0, &      ! detritus 
    !                        convers_dZm = 10.0**(-2 -3)*12.01*9.0*24.0*3600.0         ! zooplankton loss
    ! No conversion for Colleen's data: 
    real(dp), parameter :: convers_zm  = 6.625* 12.01 * 9.0 * 1000.0, &            ! zooplankton biomass mol N m-2 s-1 -to- gC ww m-2
                           convers_det = 1, &                                      ! detritus 
                           convers_dZm = 6.625*12.01*9.0*24.0*3600.0               ! zooplankton loss
    
    
end module Parameters
