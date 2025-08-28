;----- Defining breeds and variables -----
globals
[
  starting_world_file
  number-of-fibroblasts
  number-of-myofibroblasts
  number-of-macrophages
  total_world_collagen ; summing collagen
  initial_total_world_collagen
  myo_collagen
  fibro_collagen
  initial-number-of-sources
  TGFbetaDiffThresh
  pentox-TGFbetaDiffThresh
  pentox-myo_collagen
  initialSourceTGFbeta
  lowTGFbetaThresh
  highTGFbetaThresh
  percent-pixel-collagen
  uptakePercent
  trailPercent
  pirf-trailPercent
  have-dosed-pentox
  have-dosed-pirf
  clock
  starting-seed
  ;===== To avoid infinite loops in the case of single-patch collagen "islands"
  max-tries-for-chemotax
  max-tries-for-migrate
  ;===== The following globals can become sliders for behavior space
  ;percent-pixel-collagen-thresh
  ;initial-fibroblast-cells
  ;strategy-pentox
  ;strategy-pirf
  MMP-degradation-rate    ; Collagen degraded per MMP unit per tick
  MMP-secretion-rate      ; MMPs secreted per macrophage per tick
  MMP-decay-rate          ; Rate of MMP concentration decay
  ;===== Diffusion-related and units stuff
  dt ; (units sec?)
  h ; (dx = dy = h units microns?)
  TGFbeta-diffusion-coefficient ; c^2 in the heat equation (units microns^2/s?)
  TGFbeta-sigma ;
  TGFbeta-diffusion-number ; used in diffuse4 or diffuse in the GO function to diffuse TGFbeta; this number is 4*sigma (if using diffuse4) or 8*sigma (if using diffuse)
]

extensions
[
  palette
]

breed [ fibroblasts fibroblast ]
breed [ myofibroblasts myofibroblast ]
breed [ macrophages macrophage ]
breed [ TGFbeta-sources TGFbeta-source ]

patches-own
[
  total_patch_collagen
  immediate_patch_collagen
  old_collagen
  new_myo_collagen
  myo_multiplier
  new_fibro_collagen
  fibro_multiplier
  patch_TGFbeta
  patch_alveoli
  MMP-concentration
]

fibroblasts-own
[
  TGFbeta_fb
  prev-patch
  tries-for-chemotax
  tries-for-migrate
]

myofibroblasts-own
[
  TGFbeta_myo
  prev-patch
  tries-for-chemotax
  tries-for-migrate
]

;-------- Set-up and clean code ------

to clear-world
  clear-all
end

to setup
  ;===== Import world from .csv and set patch variables
  set percent-pixel-collagen 0
  ;===== Import "Healthy Lung case from ICERM"
  import-world starting_world_file ;"HistologyHealthyLung.csv"
  ;===== Import HealthyControls human patient samples
  ; HC_1.B0.1
  ;import-world "CropMaskHE/HealthyControls/V19S23-092-A1.csv"
  ; HC_1.B0.2
  ;import-world "CropMaskHE/HealthyControls/V10T03-282-A1.csv"
  ; HC_2.B0.1
  ;import-world "CropMaskHE/HealthyControls/V10T31-015-A1.csv"
  ; HC_3.B0.1
  ;import-world "CropMaskHE/HealthyControls/V10T31-019-A1.csv"
  ; HC_3.B0.2
  ;import-world "CropMaskHE/HealthyControls/V10T03-280-A1.csv"
  ; HC_4.B0.1
  ;import-world "CropMaskHE/HealthyControls/V10T03-281-A1.csv"
  ;===== Import IPF progression tissue block 1 human patient samples
  ; IPF_1.B1.1
  ;import-world "CropMaskHE/IPFprogressionB1/V19S23-092-B1.csv"
  ; IPF_1.B1.2
  ;import-world "CropMaskHE/IPFprogressionB1/V10T03-279-B1.csv"
  ; IPF_2.B1.1
  ;import-world "CropMaskHE/IPFprogressionB1/V10T31-015-B1.csv"
  ; IPF_2.B1.2
  ;import-world "CropMaskHE/IPFprogressionB1/V10T03-280-B1.csv"
  ; IPF_3.B1.2
  ;import-world "CropMaskHE/IPFprogressionB1/V10T03-281-B1.csv"
  ; IPF_4.B1.1
  ;import-world "CropMaskHE/IPFprogressionB1/V10T31-051-B1.csv"
  ; IPF_4.B1.2
  ;import-world "CropMaskHE/IPFprogressionB1/V10T03-282-B1.csv"
  ;===== Import IPF progression tissue block 2 human patient samples
  ; IPF_1.B2.1
  ;import-world "CropMaskHE/IPFprogressionB2/V19S23-092-C1.csv"
  ; IPF_1.B2.2
  ;import-world "CropMaskHE/IPFprogressionB2/V10T03-279-C1.csv"
  ; IPF_2.B2.1
  ;import-world "CropMaskHE/IPFprogressionB2/V10T31-015-C1.csv"
  ; IPF_2.B2.2
  ;import-world "CropMaskHE/IPFprogressionB2/V10T03-280-C1.csv"
  ; IPF_3.B2.2
  ;import-world "CropMaskHE/IPFprogressionB2/V10T03-281-C1.csv"
  ; IPF_4.B2.1
  ;import-world "CropMaskHE/IPFprogressionB2/V10T31-051-C1.csv"
  ;===== Import IPF progression tissue block 3 human patient samples
  ; IPF_1.B3.1
  ;import-world "CropMaskHE/IPFprogressionB3/V19S23-092-D1.csv"
  ; IPF_1.B3.2
  ;import-world "CropMaskHE/IPFprogressionB3/V10T03-279-D1.csv"
  ; IPF_2.B3.1
  ;import-world "CropMaskHE/IPFprogressionB3/V10T31-015-D1.csv"
  ; IPF_2.B3.2
  ;import-world "CropMaskHE/IPFprogressionB3/V10T03-280-D1.csv"
  ; IPF_3.B3.2
  ;import-world "CropMaskHE/IPFprogressionB3/V10T03-281-D1.csv"
  ; IPF_4.B3.1
  ;import-world "CropMaskHE/IPFprogressionB3/V10T31-051-D1.csv"
  ask patches [ifelse  pcolor = 117 [set patch_alveoli 0 set total_patch_collagen 1] [set patch_alveoli 1 set total_patch_collagen 0]  ]
  sum-collagen
  ;===== Random seed
  set starting-seed new-seed
  random-seed starting-seed ;added this line to ensure randomly distributed fibroblasts at the beginning
  ;===== Comment if using sliders
  ;set percent-pixel-collagen-thresh 75
  ;set initial-fibroblast-cells 50
  ;set strategy-pentox 0
  ;set strategy-pirf 0
  ;_____
  ;; strategy 0, no drug is applied
  ;; strategy 1, drug is applied at t = 0
  ;; strategy 2, drug is applied when percent-pixel-collagen >= 55
  ;; strategy 3, drug is appled when percent-pixel-collagen >= 65
  ;===== Set parameters
  set initial-number-of-sources 90
  set initial-number-of-macrophages 20
  set initial_total_world_collagen total_world_collagen
  set TGFbetaDiffThresh 100
  set initialSourceTGFbeta 5000
  set lowTGFbetaThresh 0.05 * initialSourceTGFbeta
  set highTGFbetaThresh 0.8 * initialSourceTGFbeta
  set myo_collagen 12
  set fibro_collagen 9
  set uptakePercent 0.00001
  set trailPercent 0.001
  create-macrophages initial-number-of-macrophages [  ; Add macrophages
    set color blue
    set size 4
    move-to one-of patches with [patch_alveoli = 0]
    set number-of-macrophages count macrophages
  ]
  set MMP-degradation-rate 0.02   ; Literature range: 0.01-0.05
  set MMP-secretion-rate 0.8      ; Based on macrophage activation
  set MMP-decay-rate  0.05         ; MMP half-life 0.1
  ask patches [set MMP-concentration 0]
  set pentox-myo_collagen 5
  set pentox-TGFbetaDiffThresh 1.5 * TGFbetaDiffThresh
  set pirf-trailPercent 0.0001
  set have-dosed-pirf 0
  set have-dosed-pentox 0
  set max-tries-for-chemotax 10
  set max-tries-for-migrate 10
  set dt 1 ; search literature for better value
  set h 1 ; search literature for better value
  set TGFbeta-diffusion-coefficient 5; c^2 in the heat equation (units microns^2/s?) search literature for better value
  set TGFbeta-sigma TGFbeta-diffusion-coefficient * dt / ( h ^ 2 )
  set TGFbeta-diffusion-number 4 * TGFbeta-sigma; used in diffuse4 or diffuse in the GO function to diffuse TGFbeta; this number is 4*sigma (if using diffuse4) or 8*sigma (if using diffuse)
  ;===== Initialize
  place-fibroblasts
  deposit-TGFbeta-on-sources
  reset-ticks
end

;------- GO!!!!!! ------

to go
  ifelse percent-pixel-collagen < percent-pixel-collagen-thresh
  [
    diffuse-TGFbeta
    manage-MMP-dynamics
    chemotax-fibroblasts
    chemotax-myofibroblasts
    differentiate-TGFbetaThresh
    ;ask patches [ifelse patch_alveoli = 1 [set patch_TGFbeta 0] [if (patch_TGFbeta > 0) and (pcolor != 115) [set pcolor palette:scale-gradient [117 15] patch_TGFbeta 0 50]]]
    if number-of-myofibroblasts >= 0.1 * initial-fibroblast-cells [ secrete-spill-collagen]
    ;===============  APPLY DRUG STRATEGIES =============
    if (have-dosed-pentox = 0) and (strategy-pentox != 0)
    [
     (ifelse
        (strategy-pentox = 1 and percent-pixel-collagen >= 0) [
          dose-pentox
    ]
    (strategy-pentox = 2 and percent-pixel-collagen >= 55) [
          dose-pentox
    ]
    (strategy-pentox = 3 and percent-pixel-collagen >= 65) [
          dose-pentox
    ]
    )
    ]
    ;~~~
    if (have-dosed-pirf = 0) and (strategy-pirf != 0)
    [
     (ifelse
        (strategy-pirf = 1 and percent-pixel-collagen >= 0) [
          dose-pirf
    ]
    (strategy-pirf = 2 and percent-pixel-collagen >= 55) [
          dose-pirf
    ]
    (strategy-pirf = 3 and percent-pixel-collagen >= 65) [
          dose-pirf
    ]
    )
    ]
    ;====================================================
    tick
  ]
  [
    stop
  ]
end

;----- Fibroblast and myofibroblast subroutines ------

;Create fibroblasts in the world, according to the specified number in the slider

to place-fibroblasts
  crt initial-fibroblast-cells
  [
    ;setxy (random-float world-width) (random-float world-height)
    set breed fibroblasts
    set shape "fibroblast"
    set color 27
    set size 5
    move-to one-of patches with [patch_alveoli = 0]
  ]
   set number-of-fibroblasts count fibroblasts
end

;Migrate fibroblasts randomly around the world

to migrate-fibroblasts-randomly
  ask fibroblasts [set prev-patch patch-here rt random-float 30 lt random-float 30 fd 1]
end

;Migrate fibroblasts randomly on purple patches only

to migrate-fibroblasts-on-non-alveoli
  ask fibroblasts [
    migrate-single-fibroblast-on-non-alveoli
  ]
end

to migrate-single-fibroblast-on-non-alveoli ;updated with TGF-beta trail and uptake
  ;pen-down
  set prev-patch patch-here
  let randDirection random-float 360
  let uptake 0.2 * patch_TGFbeta
  set TGFbeta_fb TGFbeta_fb + uptake ;setting turtle variable to 20% of the patch's TFGbeta (uptake)
  set patch_TGFbeta (patch_TGFbeta - uptake) ;setting patch variable to have 20% less TFGbeta because of uptake
  let destination patch (xcor + cos randDirection ) (ycor + sin randDirection )
  set tries-for-migrate 1
  while [ [patch_alveoli] of destination = 1 and tries-for-migrate <= max-tries-for-migrate ]
  [
    set randDirection random-float 360
    set destination patch (xcor + cos randDirection ) (ycor + sin randDirection)
    set tries-for-migrate tries-for-migrate + 1
    ]
  set heading randDirection
  move-to destination
  let trail 0.1 * patch_TGFbeta
  set patch_TGFbeta patch_TGFbeta + trail
  ;pen-up
end

to migrate-single-myofibroblast-on-non-alveoli ;updated with TGF-beta trail and uptake
  ;pen-down
  set prev-patch patch-here
  let randDirection random-float 360
  let uptake 0.2 * patch_TGFbeta
  set TGFbeta_myo TGFbeta_myo + uptake ;setting turtle variable to 20% of the patch's TFGbeta (uptake)
  set patch_TGFbeta (patch_TGFbeta - uptake) ;setting patch variable to have 20% less TFGbeta because of uptake
  let destination patch (xcor + cos randDirection ) (ycor + sin randDirection )
  set tries-for-migrate 1
  while [ [patch_alveoli] of destination = 1 and tries-for-migrate <= max-tries-for-migrate ]
  [
    set randDirection random-float 360
    set destination patch (xcor + cos randDirection ) (ycor + sin randDirection)
    set tries-for-migrate tries-for-migrate + 1
    ]
  set heading randDirection
  move-to destination
  let trail 0.1 * patch_TGFbeta
  set patch_TGFbeta patch_TGFbeta + trail
  ;pen-up
end

;Proliferate fibroblasts

to proliferate-fibroblasts
  ask fibroblasts [hatch 1 [migrate-single-fibroblast-on-non-alveoli]]
  set number-of-fibroblasts count fibroblasts
end

;Proliferate myofibroblasts

to proliferate-myofibroblasts
  ask myofibroblasts [hatch 1 [migrate-single-myofibroblast-on-non-alveoli]]
  set number-of-myofibroblasts count myofibroblasts
end

; Kill fibroblasts that are overcrowded

to apoptose-crowded-fibroblasts
  ask fibroblasts [if sum [count fibroblasts-here] of neighbors > 6 [die]]
  set number-of-fibroblasts count fibroblasts
end

; Kill myofibroblasts that are overcrowded

to apoptose-crowded-myofibroblasts
  ask myofibroblasts [if sum [count myofibroblasts-here] of neighbors > 6 [die]]
  set number-of-myofibroblasts count myofibroblasts
end

; Differentiate fibroblasts if they are in a patch of TGFbeta > TGFbetaDiffThresh

to differentiate-TGFbetaThresh
  ask fibroblasts [if patch_TGFbeta > TGFbetaDiffThresh [set breed myofibroblasts set shape "myofibroblast" set color 77 set size 5]]
  set number-of-fibroblasts count fibroblasts
  set number-of-myofibroblasts count myofibroblasts
end

; Addition of drug pentoxifylline
to dose-pentox
  set TGFbetaDiffThresh pentox-TGFbetaDiffThresh
  set myo_collagen pentox-myo_collagen
  set have-dosed-pentox 1
end

; Addition of drug Pirfenidone
to dose-pirf
  set trailPercent pirf-trailPercent
  set have-dosed-pirf 1
end

; Move fibroblasts and myofibroblasts towards higher concentration of TGFbeta (chemotaxis), if lowTGFbetaThresh < TGFbeta < highTGFbetaThresh; randomly otherwise
; restricted to interstitial space ONLY

to chemotax-fibroblasts
  ask fibroblasts
  [
    ifelse patch_TGFbeta < lowTGFbetaThresh ; random walk
    [
      migrate-single-fibroblast-on-non-alveoli
    ]
    [
      ifelse (lowTGFbetaThresh <= patch_TGFbeta) and (patch_TGFbeta < highTGFbetaThresh) ; chemotaxis zone + wiggle
      [
          set prev-patch patch-here
          let uptake uptakePercent * patch_TGFbeta
          set TGFbeta_fb TGFbeta_fb + uptake ;setting turtle variable to 20% of the patch's TFGbeta (uptake)
          set patch_TGFbeta (patch_TGFbeta - uptake) ;setting patch variable to have 20% less TFGbeta because of uptake
          move-to patch-here  ;; go to patch center
          let p max-one-of neighbors [patch_TGFbeta]  ;; or neighbors4
          if [patch_TGFbeta] of p > patch_TGFbeta [
          face p
          rt random-float 30 lt random-float 30
          fd 1
          ]
        set tries-for-chemotax 1
       while [ patch_alveoli = 1 and tries-for-chemotax <= max-tries-for-chemotax ]
       [
          move-to prev-patch
          move-to patch-here  ;; go to patch center
          set p max-one-of neighbors [patch_TGFbeta]  ;; or neighbors4
          if [patch_TGFbeta] of p > patch_TGFbeta [
          face p
          rt random-float 30 lt random-float 30
          fd 1
          ]
          set tries-for-chemotax tries-for-chemotax + 1
       ]
        ; update TGFbeta due to uptake and trail (chemotaxis case only)
        let trail trailPercent * patch_TGFbeta
        set patch_TGFbeta patch_TGFbeta + trail
      ]
      [
        migrate-single-fibroblast-on-non-alveoli ; random walk
      ]
    ]
  ]
end

to chemotax-myofibroblasts
  ask myofibroblasts
  [
    ifelse patch_TGFbeta < lowTGFbetaThresh ; random walk
    [
      migrate-single-myofibroblast-on-non-alveoli
    ]
    [
      ifelse (lowTGFbetaThresh <= patch_TGFbeta) and (patch_TGFbeta < highTGFbetaThresh) ; chemotaxis zone + wiggle
      [
          set prev-patch patch-here
          let uptake uptakePercent * patch_TGFbeta
          set TGFbeta_myo TGFbeta_myo + uptake ;setting turtle variable to 20% of the patch's TFGbeta (uptake)
          set patch_TGFbeta (patch_TGFbeta - uptake) ;setting patch variable to have 20% less TFGbeta because of uptake
          move-to patch-here  ;; go to patch center
          let p max-one-of neighbors [patch_TGFbeta]  ;; or neighbors4
          if [patch_TGFbeta] of p > patch_TGFbeta [
          face p
          rt random-float 30 lt random-float 30
          fd 1
          ]
        set tries-for-chemotax 1
       while [ patch_alveoli = 1 and tries-for-chemotax <= max-tries-for-chemotax ]
       [
          move-to prev-patch
          move-to patch-here  ;; go to patch center
          set p max-one-of neighbors [patch_TGFbeta]  ;; or neighbors4
          if [patch_TGFbeta] of p > patch_TGFbeta [
          face p
          rt random-float 30 lt random-float 30
          fd 1
          ]
          set tries-for-chemotax tries-for-chemotax + 1
       ]
        ; update TGFbeta due to uptake and trail (chemotaxis case only)
        let trail trailPercent * patch_TGFbeta
        set patch_TGFbeta patch_TGFbeta + trail
      ]
      [
        migrate-single-myofibroblast-on-non-alveoli ; random walk
      ]
    ]
  ]
end

;---- Deposit and diffuse growth factors (ligands) ------

; Deposit growth factors by colouring with your mouse the patches you want the growth factors to diffuse from.
; Wherever you click your mouse, the patch will turn white, and this will indicate a location where you want growth factor to diffuse from.

to draw-white
  if mouse-down? [ask patch mouse-xcor mouse-ycor [ set pcolor white ]]
end

to draw-red
  if mouse-down? [ask patch mouse-xcor mouse-ycor [ set pcolor red ]]
end

; The following code places and initial amount of growth factor on the patch that you coloured white with your mouse.

to deposit-TGFbeta-on-white-patches
  ask patches [if pcolor = white [set patch_TGFbeta 5000]]
end

; The following code places and initial amount of growth factor on initial-number-of-sources purple patches randomly.

to deposit-TGFbeta-on-sources
  crt initial-number-of-sources
  [
    setxy (random-float world-width) (random-float world-height)
    set breed TGFbeta-sources
    set shape "target"
    set color red
    set size 3
    move-to one-of patches with [patch_alveoli = 0]
    set patch_TGFbeta initialSourceTGFbeta
  ]
  ask TGFbeta-sources [die]
end

; The following code "diffuses" growth factor from every patch to its neighbours using the NetLogo primitive "diffuse" and restirct to purple area.

to diffuse-TGFbeta
  diffuse patch_TGFbeta .01
;  ask patches [ifelse patch_alveoli = 1 [set patch_TGFbeta 0] [if patch_TGFbeta > 0 [set pcolor scale-color blue patch_TGFbeta 0 100]]]
;  ask patches [ifelse patch_alveoli = 1 [set patch_TGFbeta 0] [if patch_TGFbeta > 0 [set pcolor palette:scale-gradient [117 15] patch_TGFbeta 0 50]]]
end

;to myofibroblast-secrete-collagen
;  ask myofibroblasts [set pcolor 116 set patch_collagen 12]
;end

to secrete-spill-collagen
  ask turtles[move-to patch-here]

  ; current patch accumuates collagen
  ask patches [accumulate-collagen]

  ; spill to neighbors to accumulate collagen there
  ask patches
  [ set myo_multiplier count myofibroblasts-here
    set fibro_multiplier count fibroblasts-here
    let myo_multiplier_neighbor myo_multiplier
    let fibro_multiplier_neighbor fibro_multiplier

    ifelse  count myofibroblasts-here > 0 ; includes myofibroblast only and combination of both types
    [ ask neighbors
      [ if patch_alveoli = 1
        [set pcolor 115 set patch_alveoli 0]

        set myo_multiplier myo_multiplier_neighbor
        accumulate-collagen
      ]
    ]
    [ if  count fibroblasts-here > 0 ; includes fibroblasts only case
      [ ask neighbors
        [ if patch_alveoli = 1
          [set pcolor 115 set patch_alveoli 0]
          set fibro_multiplier fibro_multiplier_neighbor
          accumulate-collagen
        ]
      ]
    ]
  ]
  sum-collagen
  ;tick
end

to accumulate-collagen
  set old_collagen total_patch_collagen
  set total_patch_collagen old_collagen + myo_multiplier * myo_collagen + fibro_multiplier * fibro_collagen
end


to sum-collagen
  set total_world_collagen sum [total_patch_collagen] of patches
  calculate-percent-collagen
end

to calculate-percent-collagen
  let sum-patch-collagen sum [patch_alveoli] of patches
  let domain-size world-width * world-height
  let fraction-collagen sum-patch-collagen / domain-size
  set percent-pixel-collagen 100 - 100 * fraction-collagen
end

;=== DIKSHA: This is the implementation of the MMPS that degrade the collagen

to manage-MMP-dynamics
  secrete-MMPs
  diffuse-MMPs
  decay-MMPs
  degrade-collagen
end

to secrete-MMPs
  ask macrophages [
    ;; Macrophages secrete MMPs inversely correlated with TGF-β levels
    let secretion MMP-secretion-rate * (1 - (patch_TGFbeta / highTGFbetaThresh))
    ask patch-here [
      set MMP-concentration MMP-concentration + secretion
    ]
  ]
end

to diffuse-MMPs
  diffuse MMP-concentration 0.3  ; MMP diffusion rate (slower than TGF-β)
end

to decay-MMPs
  ask patches [
    set MMP-concentration MMP-concentration * (1 - MMP-decay-rate)
  ]
end

to degrade-collagen
  ask patches [
    ;; Collagen degradation limited to areas with MMP activity
    if patch_alveoli = 1 [
      let degradation MMP-concentration * MMP-degradation-rate
      set total_patch_collagen max (list 0 (total_patch_collagen - degradation))
    ]
  ]
  sum-collagen  ; Update global collagen tracking
end
;=================================================================
@#$#@#$#@
GRAPHICS-WINDOW
936
157
1449
671
-1
-1
5.0
1
20
1
1
1
0
1
1
1
-50
50
-50
50
0
0
1
ticks
30.0

BUTTON
38
56
140
89
Clear world
clear-world
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
39
103
144
136
Set up world
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1026
93
1122
138
No. of fibroblasts
number-of-fibroblasts
17
1
11

BUTTON
38
295
203
328
Proliferate fibroblasts
proliferate-fibroblasts
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
37
343
255
376
Apoptose crowded fibroblasts
apoptose-crowded-fibroblasts
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
38
507
167
540
Diffuse TGFbeta
diffuse-TGFbeta
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
37
219
415
247
Migration, proliferation, apoptosis, & differentiation
11
0.0
1

BUTTON
41
655
269
688
Secrete and spill collagen
secrete-spill-collagen
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1136
93
1252
138
No. of myofibroblasts
number-of-myofibroblasts
17
1
11

BUTTON
36
392
297
425
Differentiate fibroblasts with TGFbeta
differentiate-TGFbetaThresh
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
37
247
275
280
Migrate fibroblasts on non-alveoli ONLY
migrate-fibroblasts-on-non-alveoli
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
38
558
333
591
Diffuse TGFbeta AND chemotax fibroblasts
diffuse-TGFbeta\nchemotax-fibroblasts\nchemotax-myofibroblasts\nask patches [ifelse patch_alveoli = 1 [set patch_TGFbeta 0] [if (patch_TGFbeta > 0) and (pcolor != 115) [set pcolor palette:scale-gradient [117 15] patch_TGFbeta 0 50]]]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
37
10
187
35
Initialisation
20
0.0
1

TEXTBOX
36
183
235
233
Fibroblasts actions
20
0.0
1

PLOT
629
287
902
557
plot 1
Time
Amount of Collagen
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy ticks total_world_collagen"

TEXTBOX
39
456
122
481
TGFbeta
20
0.0
1

TEXTBOX
41
615
191
640
Collagen
20
0.0
1

MONITOR
650
211
791
256
NIL
total_world_collagen
17
1
11

MONITOR
647
156
827
201
NIL
percent-pixel-collagen
17
1
11

BUTTON
184
61
247
94
GO!
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
182
109
328
142
Show TGFbeta profile
ask patches [if pcolor = 115 [set pcolor 117]]\nask patches [ifelse patch_alveoli = 1 [set patch_TGFbeta 0] [if (patch_TGFbeta > 0) and (pcolor != 115) [set pcolor palette:scale-gradient [117 15] patch_TGFbeta 0 50]]]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
351
61
480
94
Dose Pentoxifylline
dose-pentox
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
350
109
470
142
Dose Pirfenidone
dose-pirf
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
929
93
1016
138
Starting seed
starting-seed
0
1
11

SLIDER
533
65
705
98
strategy-pentox
strategy-pentox
0
3
0.0
1
1
NIL
HORIZONTAL

SLIDER
737
66
909
99
strategy-pirf
strategy-pirf
0
3
0.0
1
1
NIL
HORIZONTAL

SLIDER
405
245
602
278
percent-pixel-collagen-thresh
percent-pixel-collagen-thresh
50
100
75.0
5
1
NIL
HORIZONTAL

SLIDER
408
326
580
359
initial-fibroblast-cells
initial-fibroblast-cells
1
100
50.0
5
1
NIL
HORIZONTAL

SLIDER
410
391
615
424
initial-number-of-macrophages
initial-number-of-macrophages
0
100
20.0
5
1
NIL
HORIZONTAL

CHOOSER
216
10
551
55
starting_world_file
starting_world_file
"HistologyHealthyLung.csv" "CropMaskHE/HealthyControls/V19S23-092-A1.csv" "CropMaskHE/HealthyControls/V10T03-282-A1.csv" "CropMaskHE/HealthyControls/V10T31-015-A1.csv" "CropMaskHE/HealthyControls/V10T31-019-A1.csv" "CropMaskHE/HealthyControls/V10T03-280-A1.csv" "CropMaskHE/HealthyControls/V10T03-281-A1.csv" "CropMaskHE/IPFprogressionB1/V19S23-092-B1.csv" "CropMaskHE/IPFprogressionB1/V10T03-279-B1.csv" "CropMaskHE/IPFprogressionB1/V10T31-015-B1.csv" "CropMaskHE/IPFprogressionB1/V10T03-280-B1.csv" "CropMaskHE/IPFprogressionB1/V10T03-281-B1.csv" "CropMaskHE/IPFprogressionB1/V10T31-051-B1.csv" "CropMaskHE/IPFprogressionB1/V10T03-282-B1.csv" "CropMaskHE/IPFprogressionB2/V19S23-092-C1.csv" "CropMaskHE/IPFprogressionB2/V10T03-279-C1.csv" "CropMaskHE/IPFprogressionB2/V10T31-015-C1.csv" "CropMaskHE/IPFprogressionB2/V10T03-280-C1.csv" "CropMaskHE/IPFprogressionB2/V10T03-281-C1.csv" "CropMaskHE/IPFprogressionB2/V10T31-051-C1.csv" "CropMaskHE/IPFprogressionB3/V19S23-092-D1.csv" "CropMaskHE/IPFprogressionB3/V10T03-279-D1.csv" "CropMaskHE/IPFprogressionB3/V10T31-015-D1.csv" "CropMaskHE/IPFprogressionB3/V10T03-280-D1.csv" "CropMaskHE/IPFprogressionB3/V10T03-281-D1.csv" "CropMaskHE/IPFprogressionB3/V10T31-051-D1.csv"
14

MONITOR
1267
93
1392
138
No. of macrophages
number-of-macrophages
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fibroblast
true
0
Polygon -7500403 true true 90 149 145 299 209 148 148 0 91 148
Circle -7500403 true true 91 89 120
Circle -6459832 true false 114 114 72
Circle -955883 true false 121 121 58
Polygon -2674135 true false 96 167
Polygon -7500403 true true 91 148 99 196 112 221 127 251 137 267 94 153
Polygon -7500403 true true 211 164 203 116 190 91 175 61 165 45 208 159
Polygon -7500403 true true 95 140 103 92 116 67 131 37 141 21 98 135
Polygon -7500403 true true 209 135 201 183 188 208 173 238 163 254 206 140

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

myofibroblast
true
0
Polygon -7500403 true true 90 149 145 299 209 148 148 0 91 148
Circle -7500403 true true 91 89 120
Circle -6459832 true false 114 114 72
Circle -14835848 true false 121 121 58
Polygon -2674135 true false 96 167
Polygon -7500403 true true 91 148 99 196 112 221 127 251 137 267 94 153
Polygon -7500403 true true 211 164 203 116 190 91 175 61 165 45 208 159
Polygon -7500403 true true 95 140 103 92 116 67 131 37 141 21 98 135
Polygon -7500403 true true 209 135 201 183 188 208 173 238 163 254 206 140

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
