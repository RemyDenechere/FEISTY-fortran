module Parameters

    implicit none 

    ! General parameters: ---------------------------------------------
    integer, parameter  :: dp = kind(0.d0)   ! double precision
    real(dp), parameter :: zero = 0.0        ! Zero
    real(dp), parameter :: eps = 1d-30      ! Small number for divisions 
    
    ! Time series: -----------------------------------------------------
    integer, parameter  :: YR = 1            ! Number of year in Time series
    integer, parameter  :: Nmonth = 12    ! Number of month in Time series
    integer, dimension(12), parameter ::  MNTH = (/ 31, 28, 31, 30, 31, 30, &
                                                    31, 31, 30, 31, 30, 31 /) ! Length of month (days)

    ! Group information: ---------------------------------------------
    integer, parameter :: nFishGroup = 8                     ! Number of fish functional group
    integer, parameter :: nMesoZoo = 2                       ! Number of MesoZooplankton group
    integer, parameter :: nBenthos = 1                       ! Benthic resource  
    integer, parameter :: nDeriv = nFishGroup +  nBenthos    ! Number of group for witch the derivative is calculated

    ! index for the fish group: -------------------------------------
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
    
    ! =================================================================!
    ! ============= Variables to force from input file ===============!
    ! =================================================================!
    ! Experimentation parameters: ------------------------------------------
    character(LEN=20), public :: loc = "BATS"
    character(LEN=20), public :: exp = "2D" ! "COBALT_offline_BATS"
    character(LEN=30), public :: coupling = "offline"

    ! Spinup parameters: ---------------------------------------------
    integer, public :: Year_2_Spinup = 100
    logical, public :: Spinup = .false.

    ! Environemental data for test: -----------------------------------
    logical, public :: diagnostic           = .false.   ! True to run diagonostic mode 
    logical, public :: save_diagnostics     = .true.
    logical, public :: prod_constrained     = .true.
    logical, public :: Spinup_Time_Serie    = .true.
    logical, public :: Initial_Condition_generic_FEISTY = .true.
    logical, public :: largDemPel           = .false.

    ! Simulation parameters: ------------------------------------------
    real, public :: Delta_t          = 1.0             ! Time step [d]
    real, public :: IC               = 1d-5            ! Fish Initial Condition
    real, public :: PI_be_cutoff     = 200.00          ! Benthic-pelagic coupling cutoff (depth, m).
    
    ! Directories : ----------------------------------------------------
    character(LEN=280), public :: root_dir_output = "/project/rdenechere/COBALT_output/COBALT_offline_forcing_files/"
    character(LEN=280), public :: root_dir = "/project/rdenechere/CEFI-regional-MOM6-FEISTY/exps/OM4.single_column.COBALT/"

    ! namelist 
    namelist /FEISTY_nml/ Spinup, Year_2_Spinup, loc, exp, coupling, diagnostic, save_diagnostics, prod_constrained, &
                        Spinup_Time_Serie, Initial_Condition_generic_FEISTY, largDemPel, Delta_t, IC, PI_be_cutoff, &
                        root_dir_output, root_dir
    
    ! Variables ----------------------------------------------------------
    character(LEN=280), public:: root_dir_output_loc, root_dir_loc
    character(LEN=280), public :: dir_Temp, dir_zm, dir_dzm, dir_zl, dir_dzl, dir_det
    character(LEN=280), public :: var_Temp, var_zm, var_dzm, var_zl, var_dzl, var_det
    character(LEN=280), public :: dir_zt, dir_lat, dir_lon, dir_max_depth
    character(LEN=280), public :: var_zt, var_lat, var_lon, var_max_depth
    character(LEN=280), public :: Dir_IniBE, Dir_IniSf, Dir_IniSp, Dir_IniSd, Dir_IniMf, Dir_IniMp, Dir_IniMd, Dir_IniLp, Dir_IniLd
    character(LEN=280), dimension(nDeriv), public :: Dir_IC
    character(LEN=280), public :: dir_COBALT_IC, dir_FEISTY_IC_YC, dir_loc_grid
    character(len=2), dimension(nDeriv), public :: tracers_name
    character(len=33), dimension(nDeriv), public :: tracers_long_name
    character(len=2), dimension(nMesoZoo), public :: MesoZoo_name
    character(len=22), dimension(nMesoZoo), public :: MesoZoo_long_name

    ! Parameters physiology: -----------------------------------------
    real(dp), public :: ke, kmet, gamma, b_enc, h, b_cmax, a_met, b_met, eps_a, Nat_mrt
    real(dp), public :: Frate, Jselct, Aselct
    real(dp), public :: Z_s, Z_m, Z_l
    real(dp), dimension(nFishGroup), public :: Z, kappa
    real(dp), public :: kappa_l, kappa_j, kappa_a, eps_R
    real(dp), public :: Bent_eff, CC
    real(dp), public :: Sm, D, A
    real(dp), public :: pref_Mz, pref_Mf_Mz, pref_Mf_Lz, pref_Mf_S, pref_Mp_Mz, pref_Mp_Lz, pref_Mp_S
    real(dp), public :: pref_Md_BE, pref_Lp_Mf, pref_Lp_Mp, pref_Ld_Mf, pref_Ld_Mp, pref_Ld_Md, pref_Ld_BE
    real(dp), public :: convers_zm, convers_det, convers_dZm

    contains

    ! Assign values to the variables
    subroutine init_parameters
        integer :: ios

        ! Read from input.nml if it exists
        open(unit=10, file="input.nml", status="old", action="read", iostat=ios)
        call check_iostat(ios, "Error opening input.nml")

        read(10, nml=FEISTY_nml, iostat=ios)
        call check_iostat(ios, "Error reading input.nml/FEISTY_nml")   
        close(10)

        ! Directories for the location ----------------------------------------------------
        root_dir_output_loc = trim(root_dir_output) // trim(loc) // "/"
        root_dir_loc = trim(root_dir) // trim(loc) // "/"

        dir_Temp = trim(root_dir_output_loc) // "20040101.ocean_feisty_forcing.nc"
        dir_zm = trim(root_dir_output_loc) // "20040101.ocean_feisty_forcing.nc"
        dir_dzm = trim(root_dir_output_loc) // "20040101.ocean_feisty_forcing.nc"
        dir_zl = trim(root_dir_output_loc) // "20040101.ocean_feisty_forcing.nc"
        dir_dzl = trim(root_dir_output_loc) // "20040101.ocean_feisty_forcing.nc"
        dir_det = trim(root_dir_output_loc) // "20040101.ocean_feisty_forcing_detritus.nc"

        var_Temp = "thetao"                ! Temperature variable
        var_zm = "nmdz"                    ! mol/kg
        var_dzm = "jhploss_n_Mdz"          ! mol N m-2 s-1
        var_zl = "nlgz"                    ! mol/kg
        var_dzl = "jhploss_n_Lgz"          ! mol N m-2 s-1
        var_det = "Pop_btm"                ! mol m-2 s-1

        ! Information about the location: ---------------------------------
        dir_zt = trim(root_dir_output_loc) // "20040101.ocean_feisty_forcing_detritus.nc"
        dir_lat = trim(root_dir_loc) // "ocean_hgrid.nc"
        dir_lon = trim(root_dir_loc) // "ocean_hgrid.nc"
        dir_max_depth = trim(root_dir_loc) // "ocean_topog.nc"

        var_zt = "zl"
        var_lat = "y"
        var_lon = "x"
        var_max_depth = "depth"

        ! Input data (Spinup): --------------------------------------------
        Dir_IniBE = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_BE_bio_Spinup.nc"
        Dir_IniSf = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Sf_bio_Spinup.nc"
        Dir_IniSp = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Sp_bio_Spinup.nc"
        Dir_IniSd = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Sd_bio_Spinup.nc"
        Dir_IniMf = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Mf_bio_Spinup.nc"
        Dir_IniMp = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Mp_bio_Spinup.nc"
        Dir_IniMd = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Md_bio_Spinup.nc"
        Dir_IniLp = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Lp_bio_Spinup.nc"
        Dir_IniLd = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Ld_bio_Spinup.nc"

        ! Input files as array: ------------------------------------------
        Dir_IC = [   "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Sf_bio_Spinup.nc", &
                    "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Sp_bio_Spinup.nc", &
                    "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Sd_bio_Spinup.nc", &
                    "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Mf_bio_Spinup.nc", &
                    "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Mp_bio_Spinup.nc", &
                    "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Md_bio_Spinup.nc", &
                    "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Lp_bio_Spinup.nc", &
                    "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_Ld_bio_Spinup.nc", &
                    "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // &
                    "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" // trim(exp) // "_BE_bio_Spinup.nc" ]

        dir_COBALT_IC = "/project/rdenechere/CEFI-regional-MOM6-FEISTY/exps/OM4.single_column.COBALT/INPUT/&
                        &COBALT_2023_10_spinup_2003_subset.nc"
        dir_FEISTY_IC_YC = "/project/rdenechere/FEISTY-fortran/output/Yi_cheng_outputs/BE_B_IC_rescaled.nc"
        dir_loc_grid = "/project/rdenechere/CEFI-regional-MOM6-FEISTY/exps/OM4.single_column.COBALT/" // &
                        trim(loc) // "/ocean_hgrid.nc"

        ! Tracers and Mesozooplankton names
        tracers_name = ["Sf", "Sp", "Sd", "Mf", "Mp", "Md", "Lp", "Ld", "BE"]
        tracers_long_name = ["Small forage fish biomass        ", &
                            "Small large pelagic fish biomass ", &
                            "Small demersal fish biomass      ", &
                            "Medium forage fish biomass       ", &
                            "Medium large pelagic fish biomass", &
                            "Medium demersal fish biomass     ", &
                            "Large pelagic fish biomass       ", &
                            "Large demersal fish biomass      ", &
                            "Benthic invertebrate biomass     "]
        MesoZoo_name = ["Mz", "Lz"]
        MesoZoo_long_name = ["Medium MesoZooplankton", &
                             "Large MesoZooplankton "]

        ! Parameters physiology ------------------------------------------
        ke = 0.0630             ! [°c-1] Temperature correction for cmax and encounter
        kmet = 0.08550          ! [°c-1] Temperature correction for Metabolic cost
        gamma = 70.0            ! [] Coeff for mass-specific Encounter rate             
        b_enc = 0.20            ! [m-2 g^(b_enc−1) d−1] Exponent for mass-specific Encounter rate 
        h = 20.0                ! [d g^(b_cmax)] Coeff for Cmax 
        b_cmax = 0.250          ! [] Exponent for Cmax 
        a_met = 0.20 * h        ! [d-1 g^(b_met)] Coeff for Metabolic loss 
        b_met = 0.1750          ! [] Exponent for Metabolic cost 
        eps_a =  0.70           ! [] Assimilation efficiency 
        Nat_mrt = 0.10 / 365.0  ! [m-2 d-1] Natural mortality coefficient 

        ! Fishing ---------------------------------------------------------
        Frate = 0.30 / 365.0    ! [d-1] Fishing intensity 
        Jselct = 0.10           ! [] Fishing Selectivity of juveniles  
        Aselct = 1.0            ! [] Fishing Selectivity of adult 

        ! Size-class growth rate ------------------------------------------
        Z_s = 0.0010 / 0.50     ! Small fish Ratio of upper and lower body size boundary 
        Z_m = 0.50 / 250.0      ! Medium fish Ratio of upper and lower body size boundary 
        Z_l = 250.0 / 125000.0  ! Large fish Ratio of upper and lower body size boundary 
        Z = (/Z_s, Z_s, Z_s, Z_m, Z_m, Z_m, Z_l, Z_l /)
        kappa_l = 1.0           ! Larval Fraction of energy available (E_a) invested in growth 
        kappa_j = 1.0           ! Juvenile Fraction of energy available (E_a) invested in growth 
        kappa_a = 0.50          ! Adult Fraction of energy available (E_a) invested in growth 
        kappa = (/kappa_l, kappa_l, kappa_l, kappa_a, kappa_j, kappa_j, kappa_a, kappa_a/)
        eps_R = 0.010           ! Reproduction efficiency

        ! Benthic chemostat -----------------------------------------------
        Bent_eff = 0.0750       ! Benthic Efficiency from detritus to benthic biomass
        CC = 80.0               ! Carrying Capacity for benthic chemostat

        ! Feeding preferences ---------------------------------------------
        Sm = 0.25               ! Medium size feeding on Medium Zoo
        D = 0.750               ! Demersal feeding in pelagic reduction
        A = 0.50                ! Adult predation reduction

        pref_Mz = 1.0           ! Preference Small fish for medium mesozooplankton group
        pref_Mf_Mz = Sm         ! Preference for Medium Mesozooplankton   
        pref_Mf_Lz = 1.0        ! Preference for Large Mesozooplankton
        pref_Mf_S = 1.0         ! Preference for small fish
        pref_Mp_Mz = Sm         ! Preference for Medium Mesozooplankton
        pref_Mp_Lz = 1.0        ! Preference for Large Mesozooplankton
        pref_Mp_S = 1.0         ! Preference for small fish
        pref_Md_BE = 1.0        ! Preference for Benthos
        pref_Lp_Mf = 1.0 * A    ! Preference for Medium forage
        pref_Lp_Mp = 1.0        ! Preference for Medium pelagics
        pref_Ld_Mf = D * A      ! Preference for Medium forage
        pref_Ld_Mp = D          ! Preference for Medium pelagics
        pref_Ld_Md = 1.0        ! Preference for Medium Demersal
        pref_Ld_BE = 1.0        ! Preference for Benthos

        ! Unit conversion for input data ----------------------------------
        convers_zm = 6.625 * 12.01 * 9.0 * 1000.0            ! zooplankton biomass Mol N/kg --> gC WW m-3
        convers_det = 6.625 * 12.01 * 9.0 * 24.0 * 3600.0    ! detritus from molN m-2 s-1 --> gC WW m-2 d-1
        convers_dZm = 6.625 * 12.01 * 9.0 * 24.0 * 3600.0    ! zooplankton loss Mol N/kg s-1 --> gC WW m-3 d-1
    end subroutine init_parameters

    subroutine check_iostat(iostat, msg)
        integer, intent(in) :: iostat
        character(len=*), intent(in) :: msg
    
        if ( iostat == 0 ) return
        write(*,'(a,i0,/,tr3,a)') 'ERROR = ', iostat, msg
        stop
    
      end subroutine check_iostat
    
end module Parameters


! character(LEN=280), public:: &
! dir_Temp = trim(root_dir_output_loc) //  "20040101.ocean_feisty_forcing.nc", &
! dir_zm = trim(root_dir_output_loc)   //  "20040101.ocean_feisty_forcing.nc", &
! dir_dzm = trim(root_dir_output_loc)  //  "20040101.ocean_feisty_forcing.nc", &
! dir_zl = trim(root_dir_output_loc)   //  "20040101.ocean_feisty_forcing.nc", &
! dir_dzl = trim(root_dir_output_loc)  //  "20040101.ocean_feisty_forcing.nc", &
! dir_det = trim(root_dir_output_loc)  //  "20040101.ocean_feisty_forcing_detritus.nc", &
! var_Temp =  "thetao" , &
! var_zm =  "nmdz" , &          ! mol/kg
! var_dzm =  "jhploss_n_Mdz", & ! mol N m-2 s-1
! var_zl =  "nlgz" , &          ! mol/kg
! var_dzl =  "jhploss_n_Lgz",&  ! mol N m-2 s-1
! var_det = "Pop_btm",&         ! mol m-2 s-1
! ! Information about the location: ---------------------------------
! dir_zt  = trim(root_dir_output_loc) // "20040101.ocean_feisty_forcing_detritus.nc", &
! dir_lat  = trim(root_dir_loc) //'ocean_hgrid.nc',&
! dir_lon  = trim(root_dir_loc) //'ocean_hgrid.nc',&
! dir_max_depth  = trim(root_dir_loc) //'ocean_topog.nc',&
! var_zt  = "zl", &
! var_lat  = "y", &
! var_lon = "x", &
! var_max_depth = 'depth'

! ! Input data (Spinup): --------------------------------------------
! character(LEN=280), public:: &
! Dir_IniBE = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_BE_bio_Spinup.nc", &
! Dir_IniSf = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Sf_bio_Spinup.nc",&
! Dir_IniSp = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Sp_bio_Spinup.nc",&
! Dir_IniSd = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Sd_bio_Spinup.nc",&
! Dir_IniMf = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Mf_bio_Spinup.nc",&
! Dir_IniMp = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Mp_bio_Spinup.nc",&
! Dir_IniMd = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Md_bio_Spinup.nc",&
! Dir_IniLp = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Lp_bio_Spinup.nc",&
! Dir_IniLd = "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Ld_bio_Spinup.nc"

! ! Input files as array: ------------------------------------------
! character(LEN=280), dimension(nDeriv), public:: &
! Dir_IC = [   "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Sf_bio_Spinup.nc", &
! "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Sp_bio_Spinup.nc", &
! "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Sd_bio_Spinup.nc", &
! "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Mf_bio_Spinup.nc", &
! "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Mp_bio_Spinup.nc", &
! "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Md_bio_Spinup.nc", &
! "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Lp_bio_Spinup.nc", &
! "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_Ld_bio_Spinup.nc", &
! "../output/netcdf/" // trim(coupling) // "/" // trim(loc) // & 
! "/COBALT_" // trim(coupling) // "_" // trim(loc) // "_" //  trim(exp) // "_BE_bio_Spinup.nc"    ]

! character(LEN=280), public:: dir_COBALT_IC = "/project/rdenechere/CEFI-regional-MOM6-FEISTY/&
! &exps/OM4.single_column.COBALT/INPUT/COBALT_2023_10_spinup_2003_subset.nc"
! character(LEN=280), public:: dir_FEISTY_IC_YC = "/project/rdenechere/FEISTY-fortran/&
! &output/Yi_cheng_outputs/BE_B_IC_rescaled.nc"
! character(LEN=280), public:: dir_loc_grid = "/project/rdenechere/CEFI-regional-MOM6-FEISTY/&
! &exps/OM4.single_column.COBALT/" // trim(loc) // "/ocean_hgrid.nc"



! character(len=2), dimension(nDeriv)  :: tracers_name = ["Sf", "Sp", "Sd", "Mf", "Mp", "Md", "Lp", "Ld", "BE"]
! character(len=33), dimension(nDeriv) :: tracers_long_name =["Small forage fish biomass        ", &
!                                         "Small large pelagic fish biomass ", &
!                                         "Small demersal fish biomass      ", &
!                                         "Medium forage fish biomass       ", &
!                                         "Medium large pelagic fish biomass", &
!                                         "Medium demersal fish biomass     ", &
!                                         "Large pelagic fish biomass       ", &
!                                         "Large demersal fish biomass      ", &
!                                         "Benthic invertebrate biomass     "]
! character(len=2), dimension(nMesoZoo)  :: MesoZoo_name = ["Mz", "Lz"]
! character(len=22), dimension(nMesoZoo) :: MesoZoo_long_name = ["Medium MesoZooplankton", &
!                                             "Large MesoZooplankton "]

! ! Parameters physiology: ------------------------------------------
! real(dp), public:: ke = 0.0630             ! [°c-1]                Temperature correction for cmax and encounter
! real(dp), public:: kmet = 0.08550          ! [°c-1]                Temperature correction for Metabolic cost cost
! real(dp), public:: gamma = 70.0            ! []                    Coeff for mass-specific Encounter rate             
! real(dp), public:: b_enc = 0.20            ! [m-2 g^(b_enc−1) d−1] Exponent for mass-specific Encounter rate 
! real(dp), public:: h = 20.0                ! [d g^(b_cmax)]        Coeff for Cmax 
! real(dp), public:: b_cmax = 0.250          ! []                    Exponent for Cmax 
! real(dp), public:: a_met = 0.20*h          ! [d-1 g^(b_met)]       Coeff for Metabolic loss 
! real(dp), public:: b_met = 0.1750          ! []                    Exponent for Metabolic cost 
! real(dp), public:: eps_a =  0.70           ! []                    Assimilation efficiency 
! real(dp), public:: Nat_mrt = 0.10/365.0;   ! [m-2 d-1]             Natural mortality coeffient 
! ! Fishing : ---------------------------------------------------------
! real(dp), public:: Frate = 0.30/365.0      ! [d-1]                 Fishing intensity 
! real(dp), public:: Jselct = 0.10           ! []                    Fishing Selectivity of juveniles  
! real(dp), public:: Aselct = 1.0            ! []                    Fishing Selectivity of adult 

! ! Param for Size-class growth rate: ----------------------------------
! real(dp), public:: Z_s = 0.0010/0.50;      ! Small fish Ratio of upper and lower body size boundary 
! real(dp), public:: Z_m = 0.50/250.0;       ! Medium fish Ratio of upper and lower body size boundary 
! real(dp), public:: Z_l = 250.0/125000.0;   ! Large fish Ratio of upper and lower body size boundary 
! real(dp), dimension(nFishGroup) :: Z = (/Z_s, Z_s, Z_s, Z_m, Z_m, Z_m, Z_l, Z_l /)
! real(dp), public:: kappa_l = 1.0           ! Larval Fraction of energy available (E_a) invested in growth 
! real(dp), public:: kappa_j = 1.0           ! Juvenile Fraction of energy available (E_a) invested in growth 
! real(dp), public:: kappa_a = 0.50          ! Adult Fraction of energy available (E_a) invested in growth 
! real(dp), dimension(nFishGroup) :: kappa = (/kappa_l, kappa_l, kappa_l,  kappa_a, kappa_j, kappa_j, kappa_a, kappa_a/)
! real(dp), public:: eps_R = 0.010           ! Reproduction efficiency: account for energy spend in reprodutive organe, aditional foraging activities, cost of migration, and death from egg release to hatchement. 
! ! Benthic chemostat
! real(dp), public:: Bent_eff =  0.0750      ! Benthic Efficiency from detritus to benthic biomass
! real(dp), public:: CC = 80.0               ! Carring Capacity for benthic chemostat

! ! Parameters feeding preferences: ---------------------------------
! real(dp), public:: Sm = 0.25                     ! Medium size feeding on Medium Zoo
! real(dp), public:: D  = 0.750                    ! Demersal feeding in pelagic reduction
! real(dp), public:: A  = 0.50                     ! Adult predation reduction

! real(dp), public:: pref_Mz = 1.0                ! Preference Small fish for medium mesozooplankton group
! ! Medium Forage 
! real(dp), public:: pref_Mf_Mz = Sm              ! Preference for Medium Mesozooplankton   
! real(dp), public:: pref_Mf_Lz = 1.0             ! Preference for Large Mesozooplankton
! real(dp), public:: pref_Mf_S = 1.0              ! Preference for small fish
! ! Medium pelagic 
! real(dp), public:: pref_Mp_Mz = Sm              ! Preference for Medium Mesozooplankton
! real(dp), public:: pref_Mp_Lz = 1.0             ! Preference for Large Mesozooplankton
! real(dp), public:: pref_Mp_S = 1.0              ! Preference for small fish
! ! Medium Demersal  
! real(dp), public:: pref_Md_BE = 1.0             ! Preference for Benthos
! ! Large Pelagic
! real(dp), public:: pref_Lp_Mf = 1.0 * A         ! Preference for Medium forage
! real(dp), public:: pref_Lp_Mp = 1.0 
! ! Large Demersal
! real(dp), public:: pref_Ld_Mf = D * A           ! Preference for Medium forage
! real(dp), public:: pref_Ld_Mp = D               ! Preference for Medium pelagics
! real(dp), public:: pref_Ld_Md =  1.0            ! Preference for Medium Demersal
! real(dp), public:: pref_Ld_BE = 1.0             ! Preference for Benthos; 

! ! Unit conversion for input data: ---------------------------------------------- 
! real(dp), public:: convers_zm  = 6.625 * 12.01 * 9.0 * 1000.0, &            ! zooplankton biomass Mol N/kg --> gC WW m-3
!                        convers_det = 6.625 * 12.01 * 9.0 * 24.0 * 3600.0, &     ! detritus from molN m-2 s-1 --> gC WW m-2 d-1 
!                        convers_dZm = 6.625 * 12.01 * 9.0 * 24.0 * 3600.0        ! zooplankton loss Mol N/kg s-1 --> gC WW m-3 d-1