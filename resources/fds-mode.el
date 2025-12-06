;;; fds-mode.el --- Major mode for FDS (Fire Dynamics Simulator) input files -*- lexical-binding: t; -*-

;; Copyright (C) 2024
;; Author: Generated for Wang Fuk Fire project
;; Keywords: languages, simulation, fire
;; Version: 1.0.0

;;; Commentary:

;; This major mode provides syntax highlighting for FDS (Fire Dynamics
;; Simulator) input files (.fds extension).
;;
;; Features:
;; - Syntax highlighting for comments, namelists, parameters, and values
;; - All FDS 6 namelists and parameters supported
;; - Boolean, string, and number highlighting
;;
;; Installation:
;;   (add-to-list 'load-path "/path/to/this/file")
;;   (require 'fds-mode)
;;
;; Or with use-package:
;;   (use-package fds-mode
;;     :mode "\\.fds\\'")

;;; Code:

(defgroup fds nil
  "Major mode for editing FDS input files."
  :group 'languages
  :prefix "fds-")

(defface fds-namelist-face
  '((t :inherit font-lock-keyword-face :weight bold))
  "Face for FDS namelist names (e.g., &HEAD, &MESH)."
  :group 'fds)

(defface fds-parameter-face
  '((t :inherit font-lock-variable-name-face))
  "Face for FDS parameter names."
  :group 'fds)

(defface fds-boolean-face
  '((t :inherit font-lock-constant-face))
  "Face for FDS boolean values (.TRUE., .FALSE.)."
  :group 'fds)

(defface fds-terminator-face
  '((t :inherit font-lock-builtin-face))
  "Face for FDS namelist terminator (/)."
  :group 'fds)

;; All FDS 6 namelists
(defconst fds-namelists
  '("BNDF" "CATF" "CLIP" "COMB" "CSVF" "CTRL" "DEVC" "DUMP" "HEAD"
    "HOLE" "HVAC" "INIT" "ISOF" "MATL" "MESH" "MISC" "MOVE" "MULT"
    "OBST" "PART" "PRES" "PROF" "PROP" "RADF" "RADI" "RAMP" "REAC"
    "SLCF" "SM3D" "SPEC" "SURF" "TABL" "TIME" "TRNX" "TRNY" "TRNZ"
    "VENT" "WIND" "ZONE"
    ;; Evacuation module
    "EVAC" "DOOR" "SMIX" "ENTR" "EVHO" "CORR" "EVSS" "PERS" "EXIT"
    ;; End marker
    "TAIL")
  "List of all FDS namelist names.")

;; Core FDS parameters (comprehensive list)
(defconst fds-parameters
  '(;; Common parameters
    "ID" "CHID" "TITLE" "FYI"
    ;; Geometry
    "XB" "XYZ" "IJK" "DX" "DY" "DZ" "IOR" "PBX" "PBY" "PBZ"
    ;; Surface/Material references
    "SURF_ID" "SURF_IDS" "SURF_ID6" "MATL_ID" "PART_ID" "PROP_ID"
    "SPEC_ID" "CTRL_ID" "DEVC_ID" "RAMP_ID" "REAC_ID" "MULT_ID"
    "DUCT_ID" "NODE_ID" "VENT_ID" "INIT_ID" "MESH_ID"
    ;; Physical properties
    "DENSITY" "CONDUCTIVITY" "SPECIFIC_HEAT" "EMISSIVITY"
    "VISCOSITY" "DIFFUSIVITY" "HEAT_OF_COMBUSTION"
    "HEAT_OF_REACTION" "HEAT_OF_VAPORIZATION" "MW"
    "REFERENCE_TEMPERATURE" "BOILING_TEMPERATURE" "MELTING_TEMPERATURE"
    "IGNITION_TEMPERATURE" "EXTINCTION_TEMPERATURE"
    ;; Reaction parameters
    "A" "E" "N_REACTIONS" "NU_SPEC" "NU_MATL" "NU_PART"
    "N_S" "N_T" "N_O2" "SOOT_YIELD" "CO_YIELD" "HCN_YIELD"
    "RADIATIVE_FRACTION" "FUEL" "FORMULA" "C" "H" "O" "N"
    ;; Surface parameters
    "HRRPUA" "MLRPUA" "THICKNESS" "BURN_AWAY" "ADIABATIC"
    "BACKING" "COLOR" "RGB" "TRANSPARENCY" "DEFAULT"
    "TEXTURE_MAP" "TEXTURE_WIDTH" "TEXTURE_HEIGHT"
    "TMP_FRONT" "TMP_BACK" "TMP_INNER" "MASS_FLUX" "MASS_FLUX_TOTAL"
    "VEL" "VEL_T" "VOLUME_FLOW" "MASS_FLOW_RATE"
    "EXTERNAL_FLUX" "CONVECTIVE_HEAT_FLUX" "NET_HEAT_FLUX"
    "HEAT_TRANSFER_COEFFICIENT" "HEAT_TRANSFER_MODEL"
    "STRETCH_FACTOR" "CELL_SIZE_FACTOR" "GEOMETRY"
    "PARTICLE_MASS_FLUX" "PARTICLE_SURFACE_DENSITY"
    ;; Time parameters
    "T_END" "T_BEGIN" "DT" "DT_RESTART" "TIME_SHRINK_FACTOR"
    "WALL_INCREMENT" "LOCK_TIME_STEP" "RESTRICT_TIME_STEP"
    ;; Dump/output parameters
    "NFRAMES" "DT_BNDF" "DT_CTRL" "DT_DEVC" "DT_HRR" "DT_ISOF"
    "DT_MASS" "DT_PART" "DT_PL3D" "DT_PROF" "DT_SLCF" "DT_RESTART"
    "DT_FLUSH" "FLUSH_FILE_BUFFERS" "STATUS_FILES"
    "SMOKE3D" "PLOT3D_QUANTITY" "PLOT3D_SPEC_ID"
    ;; Mesh parameters
    "MPI_PROCESS" "LEVEL" "CYLINDRICAL" "CHECK_MESH_ALIGNMENT"
    "TRNX_ID" "TRNY_ID" "TRNZ_ID"
    ;; Misc parameters
    "CFL_MAX" "CFL_MIN" "VN_MAX" "VN_MIN" "CHECK_VN"
    "GVEC" "HUMIDITY" "TMPA" "P_INF" "RESTART"
    "NOISE" "TURBULENCE_MODEL" "SIMULATION_MODE"
    "SOLID_PHASE_ONLY" "FREEZE_VELOCITY" "DNS"
    "THICKEN_OBSTRUCTIONS" "SURF_DEFAULT"
    "OVERWRITE" "SHARED_FILE_SYSTEM" "VERBOSE"
    ;; HVAC parameters
    "AREA" "DIAMETER" "LENGTH" "ROUGHNESS" "LOSS"
    "DAMPER" "FAN_ID" "FILTER_ID" "AIRCOIL_ID"
    "VOLUME_FLOW" "MASS_FLOW" "MAX_FLOW" "MAX_PRESSURE"
    "EFFICIENCY" "DISCHARGE_COEFFICIENT"
    ;; Device parameters
    "QUANTITY" "QUANTITY2" "SETPOINT" "TRIP_DIRECTION"
    "INITIAL_STATE" "LATCH" "DELAY" "SMOOTHING_FACTOR"
    "ORIENTATION" "ROTATION" "STATISTICS" "POINTS"
    "TIME_AVERAGED" "TIME_HISTORY" "HIDE_COORDINATES"
    "SPATIAL_STATISTIC" "TEMPORAL_STATISTIC"
    "CONVERSION_FACTOR" "CONVERSION_ADDEND" "UNITS"
    ;; Particle parameters
    "DIAMETER" "DISTRIBUTION" "GAMMA_D" "SIGMA_D"
    "MINIMUM_DIAMETER" "MAXIMUM_DIAMETER" "MONODISPERSE"
    "INITIAL_TEMPERATURE" "SAMPLING_FACTOR" "STATIC" "MASSLESS"
    "DENSE_VOLUME_FRACTION" "DRAG_LAW" "DRAG_COEFFICIENT"
    "HORIZONTAL_VELOCITY" "VERTICAL_VELOCITY"
    "TURBULENT_DISPERSION" "BREAKUP" "AGE"
    "HEAT_OF_COMBUSTION" "QUANTITIES"
    ;; Obstruction parameters
    "REMOVABLE" "PERMIT_HOLE" "ALLOW_VENT" "OUTLINE"
    "THICKEN" "BULK_DENSITY" "INTERNAL_HEAT_SOURCE"
    "HT3D" "PYRO3D_IOR" "PYRO3D_MASS_TRANSPORT"
    ;; Vent parameters
    "SPREAD_RATE" "DYNAMIC_PRESSURE" "PRESSURE_RAMP"
    "L_EDDY" "N_EDDY" "REYNOLDS_STRESS" "VEL_RMS"
    "TMP_EXTERIOR" "TMP_EXTERIOR_RAMP" "MB"
    ;; Radiation parameters
    "RADIATION" "RADTMP" "NUMBER_RADIATION_ANGLES"
    "TIME_STEP_INCREMENT" "PATH_LENGTH" "WIDE_BAND_MODEL"
    "OPTICALLY_THIN" "ANGLE_INCREMENT" "C_MAX" "C_MIN"
    ;; Pressure parameters
    "SOLVER" "MAX_PRESSURE_ITERATIONS" "PRESSURE_TOLERANCE"
    "VELOCITY_TOLERANCE" "RELAXATION_FACTOR" "CHECK_POISSON"
    "FISHPAK_BC" "TUNNEL_PRECONDITIONER"
    ;; Control parameters
    "FUNCTION_TYPE" "INPUT_ID" "ON_BOUND" "RAMP_ID"
    "TARGET_VALUE" "PROPORTIONAL_GAIN" "INTEGRAL_GAIN"
    "DIFFERENTIAL_GAIN" "PERCENTILE"
    ;; Init parameters
    "TEMPERATURE" "MASS_FRACTION" "VOLUME_FRACTION"
    "MASS_PER_VOLUME" "MASS_PER_TIME" "N_PARTICLES"
    "N_PARTICLES_PER_CELL" "PARTICLE_WEIGHT_FACTOR"
    "SHAPE" "RADIUS" "HEIGHT" "DRY" "HRRPUV"
    ;; Ramp parameters
    "T" "F" "X" "Z" "NUMBER_INTERPOLATION_POINTS"
    ;; Slice/boundary file parameters
    "CELL_CENTERED" "VECTOR" "SLICETYPE" "AGL_SLICE"
    "MAXIMUM_VALUE" "MINIMUM_VALUE" "MESH_NUMBER"
    ;; Species parameters
    "BACKGROUND" "LUMPED_COMPONENT_ONLY" "PRIMITIVE"
    "MASS_EXTINCTION_COEFFICIENT" "AEROSOL"
    "ENTHALPY_OF_FORMATION" "REFERENCE_ENTHALPY"
    "FIC_CONCENTRATION" "FLD_LETHAL_DOSE"
    "MEAN_DIAMETER" "N_BINS" "PR_GAS"
    ;; Transformation parameters
    "CC" "PC" "IDERIV"
    ;; Zone parameters
    "LEAK_AREA" "LEAK_PRESSURE_EXPONENT" "LEAK_REFERENCE_PRESSURE"
    ;; Wind parameters
    "SPEED" "DIRECTION" "L" "Z_0" "LAPSE_RATE"
    "GROUND_LEVEL" "STRATIFICATION" "RAMP_SPEED_T" "RAMP_SPEED_Z"
    "RAMP_DIRECTION_T" "RAMP_DIRECTION_Z" "CORIOLIS_VECTOR"
    ;; Prop parameters
    "ACTIVATION_TEMPERATURE" "ACTIVATION_OBSCURATION" "RTI"
    "C_FACTOR" "FLOW_RATE" "FLOW_RAMP" "K_FACTOR"
    "OPERATING_PRESSURE" "SPRAY_ANGLE" "SPRAY_PATTERN_TABLE"
    "PARTICLES_PER_SECOND" "PARTICLE_VELOCITY"
    "OFFSET" "SMOKEVIEW_ID" "SMOKEVIEW_PARAMETERS"
    ;; Move parameters
    "AXIS" "ROTATION_ANGLE" "T34" "X0" "Y0" "Z0"
    "SCALE" "SCALEX" "SCALEY" "SCALEZ"
    ;; Mult parameters
    "DXB" "DX0" "DY0" "DZ0"
    "I_LOWER" "I_UPPER" "J_LOWER" "J_UPPER" "K_LOWER" "K_UPPER"
    "I_LOWER_SKIP" "I_UPPER_SKIP" "J_LOWER_SKIP" "J_UPPER_SKIP"
    "K_LOWER_SKIP" "K_UPPER_SKIP" "N_LOWER" "N_UPPER"
    ;; Clip parameters
    "MAXIMUM_DENSITY" "MAXIMUM_TEMPERATURE"
    "MINIMUM_DENSITY" "MINIMUM_TEMPERATURE"
    ;; Comb parameters
    "EXTINCTION_MODEL" "SUPPRESSION" "AUTO_IGNITION_TEMPERATURE"
    "AIT_EXCLUSION_ZONE" "FIXED_MIX_TIME" "FREE_BURN_TEMPERATURE"
    "MAX_CHEMISTRY_SUBSTEPS" "ODE_SOLVER" "TAU_CHEM" "TAU_FLAME"
    ;; Table parameters
    "TABLE_DATA"
    ;; Additional common parameters
    "TEXTURE_ORIGIN" "THETA" "WIDTH" "CROWN_BASE_HEIGHT"
    "CROWN_BASE_WIDTH" "TREE_HEIGHT" "PATH_RAMP" "UNIFORM" "UVW"
    "VELO_INDEX" "SKIP" "VALUE" "DELTA" "REFRACTIVE_INDEX"
    "GAS_DIFFUSION_DEPTH" "HEATING_RATE" "PYROLYSIS_RANGE"
    "REFERENCE_RATE" "ALLOW_SHRINKING" "ALLOW_SWELLING"
    "BETA_CHAR" "MAX_REACTION_RATE" "ABSORPTION_COEFFICIENT")
  "List of common FDS parameter names.")

;; Build regexp for namelists
(defconst fds-namelist-regexp
  (concat "&" (regexp-opt fds-namelists t) "\\b")
  "Regexp matching FDS namelist names.")

;; Build regexp for parameters (match parameter names before =)
(defconst fds-parameter-regexp
  (concat "\\b" (regexp-opt fds-parameters t) "\\s-*=")
  "Regexp matching FDS parameter names.")

;; Font lock keywords
(defconst fds-font-lock-keywords
  `(;; Comments (! to end of line)
    ("!.*$" . font-lock-comment-face)

    ;; Namelist names (&HEAD, &MESH, etc.)
    (,fds-namelist-regexp 1 'fds-namelist-face)

    ;; Namelist terminator (/)
    ("\\s-/\\s-*$\\|\\s-/$" . 'fds-terminator-face)

    ;; Boolean values
    ("\\.TRUE\\." . 'fds-boolean-face)
    ("\\.FALSE\\." . 'fds-boolean-face)

    ;; Parameter names (before =)
    (,fds-parameter-regexp 1 'fds-parameter-face)

    ;; Strings (single quoted)
    ("'[^']*'" . font-lock-string-face)

    ;; Numbers (integers and floats, including scientific notation)
    ("\\b[-+]?[0-9]*\\.?[0-9]+\\([eEdD][-+]?[0-9]+\\)?\\b" . font-lock-constant-face))
  "Font lock keywords for FDS mode.")

;; Syntax table
(defvar fds-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; ! starts a comment to end of line
    (modify-syntax-entry ?! "<" table)
    (modify-syntax-entry ?\n ">" table)
    ;; ' is a string delimiter
    (modify-syntax-entry ?' "\"" table)
    ;; & is punctuation
    (modify-syntax-entry ?& "." table)
    ;; / is punctuation
    (modify-syntax-entry ?/ "." table)
    ;; _ is part of words (for parameter names)
    (modify-syntax-entry ?_ "w" table)
    table)
  "Syntax table for FDS mode.")

;; Indentation (simple - FDS doesn't really need indentation)
(defun fds-indent-line ()
  "Indent current line in FDS mode."
  (interactive)
  (beginning-of-line)
  (if (bobp)
      (indent-line-to 0)
    (let ((not-indented t)
          cur-indent)
      ;; Simple indentation: align with previous non-blank line
      ;; or indent continuation lines
      (if (looking-at "^\\s-*&")
          ;; Namelist start - no indent
          (setq cur-indent 0)
        (save-excursion
          (forward-line -1)
          (while (and (looking-at "^\\s-*$") (not (bobp)))
            (forward-line -1))
          (if (looking-at "^\\s-*&.*[^/]\\s-*$")
              ;; Previous line is start of namelist without terminator
              (setq cur-indent 6)
            (setq cur-indent 0))))
      (indent-line-to (or cur-indent 0)))))

;;;###autoload
(define-derived-mode fds-mode prog-mode "FDS"
  "Major mode for editing FDS (Fire Dynamics Simulator) input files.

\\{fds-mode-map}"
  :syntax-table fds-mode-syntax-table
  (setq-local comment-start "! ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "!+\\s-*")
  (setq-local font-lock-defaults '(fds-font-lock-keywords nil t))
  (setq-local indent-line-function #'fds-indent-line))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.fds\\'" . fds-mode))

(provide 'fds-mode)

;;; fds-mode.el ends here
