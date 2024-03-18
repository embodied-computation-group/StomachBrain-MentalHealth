function [P, weightY, weightX] = CCA_plots(Project, mode2plot, weighttype, savepath, beh_labels)
    
    % [P, weightY, weightX] = CCA_plots('_Project_StomachBrain', 1, 'correlation', '/home/leah/Git/StomachBrain/StomachBrainCCA/figures/gastricPLV_PsychScoresSubscales/CCAPLS_toolkit/', {'Autism', 'ADHD.A', 'ADHD.B', 'Empathy.Fantasy', 'Empathy.Concern', 'Empathy.Perspective', 'Empathy.Distress', 'Insomnia', 'Intero.Notice', 'Intero.Not.Distract', 'Intero.Not.Worry', 'Intero.Attention.Regulation', 'Intero.Emotion.Aware', 'Intero.Self.Regulate', 'Intero.Body.Listen', 'Intero.Trusting' , 'Depression.B', 'Physical.Fatigue', 'General.Fatigue', 'Reduced.Active', 'Reduced.Motivation', 'Mental.Fatigue', 'Support.Sig.Other', 'Support.Family', 'Support.Friend', 'Depression.A', 'Somatic.Symptoms', 'Stress', 'Social.Anxiety', 'Anxiety.Trait', 'Well-Being', 'Ment.Well-Being', 'Quality.Life.General', 'Quality.Life.Physical', 'Quality.Life.Psychological', 'Quality.Life.Social', 'Quality.Life.Environment'} ) 

    %% plotting
    % Set path for plotting and the BrainNet Viewer toolbox
    set_path('plot', 'brainnet');
    addpath('/Users/au704655/Documents/Packages/spm12/')
    
    % % load cfg file for effect of interest
    filepath = ['/home/leah/Git/connectivity_tools/toolboxes/matlab/cca_pls_toolkit-master/' Project '/framework/'];
    framework = 'cca_pca_holdout5-0.40_subsamp5-0.40'; 
    cfg = load([filepath, framework, '/cfg_1.mat']);
    
    % Load res
    res.dir.frwork = cfg.cfg.dir.frwork;
    res.frwork.level = mode2plot;
    % get the correlation between the input variables and the latent variables/projections
    res.gen.weight.type = weighttype; % 'correlation' for structure correlations/loadings & 'weight' for true model weights
    % res.gen.selectfile = 'none';
    % res.gen.weight.flip = 1;
    res = res_defaults(res, 'load');
    
    %% Plot scatterplot of data projections (Connectome * Factor Canonical Variates)
    % P = projections 
    P = plot_proj(res, {'X' 'Y'}, res.frwork.level, 'osplit', res.frwork.split.best, ...
        'training+test', '2d_group', 'gen.axes.FontSize', 20, ...
        'gen.legend.FontSize', 20, 'gen.legend.Location', 'NorthWest', ... 
        'proj.scatter.SizeData', 120, 'proj.scatter.MarkerEdgeColor', 'k', ...
        'proj.scatter.MarkerFaceColor', [0.3 0.3 0.9; 0.9 0.3 0.3], ...
        'proj.xlabel', 'Brain Variate', ...
        'proj.ylabel', 'Beh Variate', ...
        'proj.lsline', 'on');
        load([res.dir.frwork, sprintf('/res/level%d/model_1.mat', mode2plot)])
        title({sprintf('r = %.03f , p = %.03f', round(correl(res.frwork.split.best),3), round(res.stat.pval(res.frwork.split.best),3)),},'fontsize',18)
        
        xlim([min(P(:,1))-0.02 max(P(:,1))+0.02])
        ylim([min(P(:,2))-0.02 max(P(:,2))+0.02])
    
    saveas(gcf,[savepath, 'scatter_CCAvariates_testtrain.png'])
  
  
    %% calculate weights
    weightX = calc_weights('X', res.frwork.split.best, res, cfg.cfg);
    weightY = calc_weights('Y', res.frwork.split.best, res, cfg.cfg);
   
    %% Plot scatterplot of Connectome * Factor Canonical Variates and color by most influential variable
    % Edit figure properties
    fontName    = 'Helvetica';
    fontSize    = 18;
    dotsize         = 65;
    
    plotX           = P(:,1);%vargout.Q'*vargout.U(:,mode2plot); % connectome projections
    plotY           = P(:,2);%vargout.Q'*vargout.V(:,mode2plot); % body wandering factor projections
    rawdata_path = ['/home/leah/Git/connectivity_tools/toolboxes/matlab/cca_pls_toolkit-master/', Project, '/data/'];
    peak_idx = find(abs(weightY) == max(abs(weightY)));
    peak_var      = load([rawdata_path, 'Y.mat']); peak_var = peak_var.Y(:,peak_idx);
    
    figure
    set(gcf,'color','w');
    scatter(plotX, plotY, dotsize, peak_var,'filled') %%%%%%%%%%%%%%%%%%
    
    load([filepath, framework, sprintf('/res/level%d/model_1.mat',mode2plot)])
    title({sprintf('CCA Mode %d', mode2plot), sprintf('r = %.03f , p = %.03f', round(correl(res.frwork.split.best),3), round(res.stat.pval(res.frwork.split.best),3))},'fontsize',fontSize)

    ylabel(sprintf('Task Variate'),'fontsize',fontSize);
    xlabel(sprintf('Imaging Variate'),'fontsize',fontSize);
    set(gca,'FontName',fontName,'fontsize',fontSize)
    legend(beh_labels{peak_idx},'Location','southwest');legend boxoff ; %%
    
    xlim([min(P(:,1))-0.02 max(P(:,1))+0.02])
    ylim([min(P(:,2))-0.02 max(P(:,2))+0.02])
     
    saveas(gcf, [savepath, sprintf('scatter_CCAvariates_%s.png',beh_labels{peak_idx})])
    
    
    %% Heatmap of behavioural weights
    % Edit figure properties
    fontName    = 'Helvetica';
    fontSize    = 18;
    
    subplot(1,2,1);
    Aload = weightX;%wX_corr;%corr(vargout.Q'*vargout.Y0,vargout.Q'*vargout.U);
    imagesc(Aload); colorbar %imagesc(Aload(res.frwork.split.best,:)'); colorbar
    ylabel(sprintf('Original variables'),'fontsize',fontSize);
    xlabel(sprintf('Canonical variables'),'fontsize',fontSize);
    title({'Imaging side',''}','fontsize',fontSize);
    % daspect([1 1 1])
    
    set(gca,'FontName',fontName,'fontsize',fontSize-8)
    
    subplot(1,2,2)
    Bload = weightY;%wY_corr; %corr(vargout.Q'*vargout.X0,vargout.Q'*vargout.V);
    imagesc(Bload); colorbar %imagesc(Bload(res.frwork.split.best,:)'); colorbar
    title({'Task side',''},'fontsize',fontSize-2);
    ylabel(sprintf('Original variables '),'fontsize',fontSize-2);
    xlabel(sprintf('Canonical variables '),'fontsize',fontSize-2);
    %daspect([1 1 1])

    % Set color axis limits to ensure symmetry
    %caxis([-max(abs(Bload(:))), max(abs(Bload(:)))]);

    varNames = beh_labels;

    yticks(1:length(varNames))
    yticklabels(varNames)
    %ytickangle(45)
    set(gcf,'color','w');
    set(gca,'FontName',fontName,'fontsize',fontSize-10)
    
    if strcmp(weighttype, 'correlation')
        sgtitle('CCA Loadings (structure correlations)','fontsize',fontSize+2) 
        saveas(gcf, [savepath, 'heatmap_CCAloadings.png'])
    elseif strcmp(weighttype, 'weight')
        sgtitle(sprintf(sprintf('CCA %ss', weighttype)),'fontsize',fontSize+2) 
        saveas(gcf, [savepath, 'heatmap_CCAweights.png'])
    end

    %save('/home/leah/Git/StomachBrain/StomachBrainCCA/scripts/python/CCAdata2plot/CCAPLS_toolkit/brainloadings_Psychsubscales_CCA1', 'weightX')
    %save('/home/leah/Git/StomachBrain/StomachBrainCCA/scripts/python/CCAdata2plot/CCAPLS_toolkit/psychloadings_Psychsubscales_CCA1', 'weightY')


    %% ordered bar plot of beh loadings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [~, I] = sort(Bload, 'descend');
    figure;
    bh = bar(reordercats(categorical(varNames(I)), varNames(I)), Bload(I), 'FaceColor', 'flat');

    % Define a custom colormap of your choice
    custom_colormap = flipud(parula(length(I)));  % flipud reverse colourmap
    colormap(custom_colormap);

    % Set the colors of each bar individually based on Bload values
    for i = 1:length(I)
        bh.CData(i, :) = custom_colormap(i, :);
    end

    title('CCA Loadings (structure correlations)', 'fontsize', fontSize-5);
    ylabel('CCA loadings');
    xlabel('Psych variables');
    box off;

    saveas(gcf, [savepath, 'barplot_CCAloadings.png']);


    %% ordered vertical bar plot (coloured bars by intensity) %%%%%%%%%%%%%%%%
    [~, I] = sort(Bload, 'descend');
    figure;
    bh = barh(reordercats(categorical(varNames(I)), varNames(I)), Bload(I), 'FaceColor', 'flat');

    set(gcf, 'Position', [100, 100, 600, 800]);  % Adjust the values as needed
    set(gca, 'Position', [0.7, 0.1, 0.25, 0.8]);

    xlabel('CCA loadings');
    ylabel('Psych variables');
    box off;

    custom_colormap = flipud(cool(length(I)));  %flipud reverses colours
    colormap(custom_colormap);
    % Set the colors of each bar individually based on Bload values
    for i = 1:length(I)
        bh.CData(i, :) = custom_colormap(i, :);
    end
    % Save the figure
    saveas(gcf, [savepath, 'barplot_CCAloadings_vert.png']);

    
    %% Plot hyperparameter surface for grid search results
    %plot_paropt(res, 1, {'correl', 'simwx', 'simwy'}, ...
    %'gen.figure.Position', [500 600 1200 400], 'gen.axes.FontSize', 20, ...
    %'gen.axes.XScale', 'log', 'gen.axes.YScale', 'log');
    
    % plotting grid search results
    %plot_paropt(res, 1, {'trcorrel', 'correl'}, ...
    %'gen.figure.Position', [500 600 800 400], 'gen.axes.FontSize', 20, ...
    %'gen.axes.XScale', 'log', 'gen.axes.YScale', 'log');


    %% Get CCA results for table
    res = res_defaults(res, 'load');

    % always look at most sig data split (res.frwork.split.best)? 
    load([res.dir.frwork, sprintf('/res/level%d/model_1.mat', mode2plot)])
    
    % Weight Stability - Connecitivity:
    sprintf('Brain (X) Weight Stability = %0.3f', round(mean(simwx(res.frwork.split.best,:)),3))
    
    % Explained Variance - Connectivity (in-sample - recommended):
    sprintf('Brain (X) Explained Variance (in-sample) = %0.3f', round(trexvarx(res.frwork.split.best),3))
    
    % Weight Stability - Mind-Wandering:
    sprintf('Behaviour (Y) Weight Stability = %0.3f', round(mean(simwy(res.frwork.split.best,:)),3))
    
    % Explained Variance - Mind-Wandering (in-sample - recommended):
    sprintf('Behaviour (Y) Explained Variance (in-sample) = %0.3f', round(trexvary(res.frwork.split.best),3))
    
    % In-Sample Correlation
    sprintf('CCA in-sample Correlation = %0.3f', round(trcorrel(res.frwork.split.best),3))
    % no p-val for in-sample correlation (because permutations based on predictive framework not descriptive)
    
    % Out-of-Sample Correlation - model generalizability 
    sprintf('CCA out-of-sample Correlation = %0.3f, p = %0.3f', round(correl(res.frwork.split.best),3), round(res.stat.pval(res.frwork.split.best),3))
    
    % Robustness (number of significant data splits) of the CCA model
    sprintf('Robustness of CCA model = %d percent', (sum(res.stat.pval < (0.05 / length(res.stat.pval))) / length(res.stat.pval)) * 100)

end
