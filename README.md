# Increased Stomach-Brain Coupling Indexes a Dimensional Signature of Negative Mental Health 

### Abstract
Visceral rhythms orchestrate the physiological states underlying human emotion. Chronic aberrations in these brain–body interactions are implicated in a broad spectrum of mental health disorders. However, the relationship between gastric–brain coupling and affective symptoms remains poorly understood. Here we investigated the relationship  between this novel interoceptive axis and mental health in 243 participants, using a cross-validated machine learning approach. We find that  increased frontoparietal brain coupling to the gastric rhythm indexes a dimensional signature of poorer mental health, spanning anxiety, depression, stress and well-being. Control analyses confirm the specificity  of these interactions to the gastric–brain axis. Our study proposes  coupling between the stomach and brain as a factor in mental health  and offers potential new targets for interventions remediating aberrant brain–body coupling.

## Summary of Repository

This repository contains:
- data (EGG, control neurological, stomach-brain coupling, (mental health data available upon reasonable request and formation of a data handling agreement))
- figures (CCA input and results figures, methods figures, and final figures for manuscript)
- results (details of results from CCA analysis)
- scripts (ReadMe.md in this folder details order of scripts to run)

## Paper & Preprint:

Lint to [NatureMentalHealth] (https://www.nature.com/articles/s44220-025-00468-6)
Link to [preprint](https://www.biorxiv.org/content/10.1101/2024.06.05.597517v3)

Cite as:
Banellis, L., Rebollo, I., Nikolova, N., & Allen, M. (2025). Stomach–brain coupling indexes a dimensional signature of mental health. Nature Mental Health, 1-10.

## Figures


### Figure 1:
| ![Mental Health Stomach-Brain Coupling CCA: ](figures/final_figs/Fig1/PsychiatricStomachBrain_CCA.png)  |
|:--:| 
| Figure 1: Canonical Correlation Analysis of stomach-brain coupling and mental health. |
>The process and outcomes of correlating stomach–brain phase coupling with mental health, as quantified by 37 variables from 16 validated surveys. The top left quadrant presents these variables organized into their respective mental health categories (categorized for visualization only, the CCA incorporated 37 individual scores), and their distribution is visualized as histograms on the bottom left, reflecting the range of participant mental health profiles. EGG data depicted on the top right demonstrates the extraction of gastric cycle frequency from raw EGG signals, power spectra and their phase information, essential for identifying stomach–brain coupling. The middle right figure illustrates coupled versus uncoupled states in stomach–brain interaction, with the individual variability in coupling strength highlighted across three brain images from individual participants (plotted on a standard mni152 brain template using MRIcroGL: visualized Montreal Neurological Institute (MNI) coordinates plotted: 28, −19, 26, thresholded at 0.1, and small clusters <1,000 mm3 removed). For the CCA, stomach–brain phase coupling is parcellated over 209 brain regions identified using the DiFuMo atlas, shown on the bottom right. The CCA model, depicted centrally, outputs a stomach–brain signature correlating with mental health individual profiles. This pattern is represented by canonical variates, which are weighted combinations of the multidimensional mental health and stomach–brain coupling data (illustrated as the central scatter plot). These weights, depicted as bar graphs, capture the most notable relationships between gastric–brain coupling and mental health profiles. 

### Figure 2:
| ![Mental Health Signature of Stomach-Brain Coupling: ](figures/final_figs/Fig2/CCAmode.png) |
|:--:| 
| Figure 2: Mental health functional correlate of stomach-brain coupling. |
>CCA results depicting the correlation between stomach–brain coupling and mental health dimensions. This indicated diminished frontoparietal stomach–brain coupling with healthier mental health scores (that is, lower anxiety, depression and stress, and higher quality of life and well-being). Left: the CCA loadings (structure correlations: Pearson’s correlations between raw mental health and stomach–brain coupling variables and their respective canonical variate). Importantly, this represents the pattern of mental health data that is maximally correlated with the stomach–brain coupling canonical variate.  High negative loadings are shown for anxiety, depression, stress, fatigue, ADHD, somatic symptoms and insomnia, while high positive loadings are shown for  well-being and quality of life. Middle: the top five parcellated regions  (DiFuMo parcellation) with the absolute highest stomach–brain coupling loadings (all negative), colored according to their respective CCA loading: left superior angular gyrus, right posterior supramarginal gyrus, left inferior precentral sulcus, left posterior superior frontal gyrus and left posterior intraparietal sulcus (plotted on a standard mni152 brain template using MRIcroGL: Montreal Neurological Institute (MNI) coordinates: −34, −3, 48). Right: the cross-validated CCA result denoting the maximally correlated psychological variate and brain–stomach coupling variate (in-sample r(118) = 0.886, out-sample r(77) = 0.323, P = 0.001, two-tailed).


### Figure 3:
| ![CCA Loadings Averaged Summary: ](figures/final_figs/Fig3/CCAloadings_Summary.png) |
|:--:| 
| Figure 3: CCA loadings averaged summary. |
>Canonical loadings (structure correlations: Pearson’s correlations between raw inputted variables and respective canonical variate) from the mental-health-associated stomach–brain coupling CCA, summarized via averaging. Note that there are prominent negative average stomach–brain loadings in the ‘dorsal attention B’ network and the ‘control A’ network, associated with reduced average depression, stress, anxiety and fatigue and increased average well-being and quality of life (that is, better mental health). The opposite pattern is also true: increased average stomach–brain loadings in attention and control networks is associated with worse mental health (increased depression, stress, anxiety and fatigue and reduced well-being and quality of life). Left: the stomach–brain loadings averaged according to  Yeo 7-networks. Top: these network-averaged stomach–brain loadings projected onto a mask of the DiFuMo atlas regions for each Yeo 7-network (from left to right: DorsAttnB, Dorsal Attention B; ContA, Control A; SalVentAttnA, Salience Ventral Attention A; SomMotA, Somatomotor A; Unassigned, no network found; VisCent, Visual A; DefaultB, Default Mode B; LimbicA, Limbic A)44, plotted on a standard mni152 brain template using MRIcroGL: Montreal Neurological Institute (MNI) coordinates: −34, −3, 48. Right: the psychological loadings averaged across mental health categories defined for visualization in Fig. 1.
