function weight = calc_weights(mod, split, res, cfg)
    % Load weights
    weight = loadmat(res, fullfile(res.dir.res, 'model.mat'), ['w' mod]);
    weight = weight(split,:)';
            
    % Process weights
    if strcmp(res.gen.weight.type, 'correlation')
        if ismember(cfg.machine.name, {'cca' 'rcca'})
            % Load data in feature space
            [trdata, trid, tedata, teid] = load_data(res, {['R' mod]}, 'osplit', split);
            data = concat_data(trdata, tedata, {['R' mod]}, trid, teid);
            
            % Load parameters
            param = loadmat(res, fullfile(res.dir.res, 'param.mat'), 'param');
            
            % Define feature index
            featid = get_featid(trdata, param(split), mod);
            
            % Project data in feature space
            weight = trdata.(['V' mod])(:,featid)' * weight;
            P = calc_proj(data.(['R' mod])(:,featid), weight);
        end
        
        % Load data in input space
        [trdata, trid, tedata, teid] = load_data(res, {mod}, 'osplit', split);
        data = concat_data(trdata, tedata, {mod}, trid, teid);
        
        % Compute correlation between input data and projection
        weight = corr(P, data.(mod), 'rows', 'pairwise')';
    end
    
    weight(isnan(weight)) = 0;
    
    % Postprocess weights (sorting, filtering etc.)
    if isfield(res.gen.weight.type, 'weight') 
        [weight, iweight] = postproc_weight(res, weight, modtype);
    end
end