# TSVR 
## Preliminary Results :heartpulse:
This repository contains preliminary results of the study called "Behavioural changes induced by tactile stimulation in VR". 

**The expirience is built in:**
* Virtual Reality using Unity. 
* The Heart Rate data is colected using Arduino Uno and a SparkFun Single Lead Heart Rate Monitor - AD8232. 
* The VR expirience displayed and tracked using a HTC Vive headset, two lighthouses and Haptic Data Globes. 

On each trial, the participants had to memorize the correct placement position on a 18 position board. Then, the ball would appear allocated randomly on either the left or the right hand and finally they had to place the ball in the correct position as fast as possible. 

The study consisted of 3 blocks of 36 trials, mounting to a goal of 108 observation per participants. 

![diagram](proposal2.png)

**Hypothesis measurments** 

1. The effect of haptic stimulation:

    * 1.a Main effect of stimulation (congruent, incongruent, absent) on ball placement accuracy.
    For example: participants are most accurate in congruent trials, a little less accurate in absent trials, least accurate in incongruent trials.
   
    * 1.b Main effect of stimulation (congruent, incongruent, absent) on ball placement time.The research was carried out inserting to the participant into a room in which he had to 
   
**In the repository you will find:**

   * Readme file
   * Folder with Data Examples
   * Folder with Matlab Files containing the data organization, outlier removal, subsetting and ECG signal processing.
      * all_participants.m (goes over all participants and builds a structure with all the data)
         * load_everything.m (how to load the files)
         * building_response_time.m (builds response time structure)
            * feedbacktype_check.m(checks number of stimuli per participant)
      * preparing_for_R.m (this file rescues the structured data, saves it as s csv file to later use in R and continues to add the mistakes)
      * HEART.m   
   * Folder with R files containing the ANOVAS and Graphs.
      * anovas.R
   


