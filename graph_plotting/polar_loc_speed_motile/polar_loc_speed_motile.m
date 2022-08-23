%% Plots speed, polar localization motile average index and polar localization vs speed

clear all
close all

only_plot = 0; % if 0 reads, analyses and saves before plotting
save_graphs = 0;
two_ch = 1; % 1 if you want to plot from two channel data, 0 uses only the first channel even if there are two

addition = '_noSL'; % filename addition of the variables.mat file: '_noSL' if speed_limit = 0

mean_median = 'mean'; % defines if mean or median speed over all tracked timepoints

%% Run save function
addpath('functions');
if ~only_plot
    [data_dir_name, data_name] = save_polar_loc_speed_motile(mean_median,two_ch,addition);
else
    data_dir = 'C:\Users\mkuehn\git\bs_Twitch\results\polar_loc_speed_motile\mat_files\';
    data_name = 'name'; % if only_plot = 1 copy the name of the mat file you want to plot WITHOUT .mat
    data_dir_name = strcat(data_dir,data_name,'.mat');
end

%% Pre-run Settings
dir_func='C:\Users\mkuehn\git\bs_Twitch\';
save_dir = 'C:\Users\mkuehn\git\bs_Twitch\results\polar_loc_speed_motile\';
save_name = regexprep(data_name, strcat('_polar_loc_speed_motile',addition),'_');

load(data_dir_name) % loads analysis file that was done with function "save_displacement_maps.m"

%% set options

tos = "2h";

plot_violin = 1; % plots distribution of single-track values as violin plot

plot_speed = 1; % plots speed
plot_polLoc = 1; % plots ratio polar intensity vs cytoplasm
plot_polLoc_speed = 1; % plots polar localization motile index vs speed, single track
plot_polLoc_vs = 1;

rep_colour = 1;
type_ratio = "mean"; % "mean" or "max" or "total"

y_speed = 0.1;  % y-axis of speed plots
y_polLoc = 2.5;  % y-axis of pole vs cytoplasm ratio plots
scaling_violin_speed = 0.02; % scaling width of violin plots
scaling_violin_polLoc = 0.2; % scaling width of violin plots

no_move = 0.007; % manually entered rough threshold for non-moving cells
no_polLoc = 0.65; % manually entered rough threshold for non-moving cells

aspect_data = 2; % 1/aspect_speed = width of the speed plot

%% Start looping

% Strains
Pil_types=unique([polar_loc_speed_motile_results{:,1}]);
nbr_strains = size(Pil_types,2);

% load functions
addpath(strcat(dir_func,'Functions')); 

% Diagram
colour = ["k","r","b","g","c","m","y"];

%% Plot speed all tracks

if plot_speed
    figure('units','normalized','outerposition',[0 0 1/aspect_data 1])
    axis([0 nbr_strains+2 0 y_speed])
    hold on
    set(gca, 'XTickLabel',["",Pil_types(1:nbr_strains)], 'Fontsize',15, 'Ticklabelinterpreter', 'none')
    xticks([0:1:nbr_strains+1])
    xtickangle(15)
    ylabel("Twitching Speed (�m/s)")

    x_val = [];
    leg=[];
    for strain = 1:1:nbr_strains
        if nbr_strains<8
            colour_data = strcat(colour(strain)," o");
        else
            colour_data = strcat(colour(1)," o");
        end
        leg=[leg,Pil_types(strain)];  
               
        type=Pil_types(strain);
        index_type=find([polar_loc_speed_motile_results{:,1}]==type);
        nbr_replicates = size(index_type,2);

        x_val = [x_val,strain];
        for rep = 1:1:nbr_replicates
            if ~isempty(polar_loc_speed_motile_results{index_type(rep),3})
                plot(x_val(strain),polar_loc_speed_motile_results{index_type(rep),4},colour_data,'MarkerSize',8,'Linewidth',1) % plots median speed of the replicate
            end
        end
        mean_data = mean([polar_loc_speed_motile_results{index_type,4}]);       
        plot([x_val(strain)-0.15 x_val(strain)+0.15],[mean_data mean_data],'k -','Linewidth',3) % plots mean speed over all replicates  
        text(x_val(strain), 0.005, num2str(polar_loc_speed_motile_concat{strain,7}), 'HorizontalAlignment','center'); % plots number of tracks
        if plot_violin
            violin(x_val(strain), polar_loc_speed_motile_concat{strain,3},'facealpha',0.42,'linewidth',0.5,'style',2,'side','right','scaling',scaling_violin_speed) % plots distribution of single-track values combined for all replicates
        end
    end
    
    plot([0 nbr_strains+2],[no_move no_move],'k --','Linewidth',1)
    text(0.03,no_move+0.0015,"rough no-move threshold",'FontSize',8)
    title(strcat("Cell speed after ",tos," on surface"));
    
    graph_type = strcat('speed',addition);
    if save_graphs
        saveas(gcf,strcat(save_dir,save_name,graph_type,'.jpg'));
        saveas(gcf,strcat(save_dir,'fig_files\',save_name,graph_type,'.fig'));
        saveas(gcf,strcat(save_dir,'svg_files\',save_name,graph_type,'.svg'));
    end
end

%% Plot polar to cytoplasmic ratio all tracks channel 1 (typically mNG)

if plot_polLoc
    [type_ratio_position] = type_ratio_position_function(type_ratio);
    
    figure('units','normalized','outerposition',[0 0 1/aspect_data 1])
    axis([0 nbr_strains+2 0 y_polLoc])
    hold on
    set(gca, 'XTickLabel',["",Pil_types(1:nbr_strains)], 'Fontsize',15, 'Ticklabelinterpreter', 'none')
    xticks([0:1:nbr_strains+1])
    xtickangle(15)
    ylabel(strcat("Ratio pole vs cytoplams intensities (",type_ratio,", mNG)"))

    x_val = [];
    leg=[];
    for strain = 1:1:nbr_strains
        if nbr_strains<8
            colour_data = strcat(colour(strain)," o");
        else
            colour_data = strcat(colour(1)," o");
        end
        leg=[leg,Pil_types(strain)];  
               
        type=Pil_types(strain);
        index_type=find([polar_loc_speed_motile_results{:,1}]==type);
        nbr_replicates = size(index_type,2);

        x_val = [x_val,strain];
        for rep = 1:1:nbr_replicates
            if ~isempty(polar_loc_speed_motile_results{index_type(rep),3})
                plot(x_val(strain),polar_loc_speed_motile_results{index_type(rep),type_ratio_position(1)},colour_data,'MarkerSize',8,'Linewidth',1) % plots median polar loc ratio of the replicate
            end
        end
        mean_data = mean([polar_loc_speed_motile_results{index_type,type_ratio_position(1)}]);           
        plot([x_val(strain)-0.15 x_val(strain)+0.15],[mean_data mean_data],'k -','Linewidth',3) % plots mean polar loc ratio over all replicates  
        text(x_val(strain), 0.05, num2str(polar_loc_speed_motile_concat{strain,7}), 'HorizontalAlignment','center'); % plots number of tracks
        if plot_violin
            violin(x_val(strain), polar_loc_speed_motile_concat{strain,type_ratio_position(2)},'facealpha',0.42,'linewidth',0.5,'style',2,'side','right','scaling',scaling_violin_polLoc) % plots distribution of single-track values combined for all replicates
        end
    end
    
    plot([0 nbr_strains+2],[no_polLoc no_polLoc],'k --','Linewidth',1)
    text(0.03,no_polLoc+0.03,"rough localization threshold FimW",'FontSize',8) % this threshold should be checked again
    title(strcat("Polar localization ratio after ",tos," on surface"));
    
    graph_type = strcat('polLoc_ratio',addition,'_',type_ratio,'_mNG');
    if save_graphs
        saveas(gcf,strcat(save_dir,save_name,graph_type,'.jpg'));
        saveas(gcf,strcat(save_dir,'fig_files\',save_name,graph_type,'.fig'));
        saveas(gcf,strcat(save_dir,'svg_files\',save_name,graph_type,'.svg'));
    end
end

%% Plot polar to cytoplasmic ratio all tracks channel 2 (typically mScI)
if two_ch
    if plot_polLoc
        [type_ratio_position] = type_ratio_position_function(type_ratio);

        figure('units','normalized','outerposition',[0 0 1/aspect_data 1])
        axis([0 nbr_strains+2 0 y_polLoc])
        hold on
        set(gca, 'XTickLabel',["",Pil_types(1:nbr_strains)], 'Fontsize',15, 'Ticklabelinterpreter', 'none')
        xticks([0:1:nbr_strains+1])
        xtickangle(15)
        ylabel(strcat("Ratio pole vs cytoplams intensities (",type_ratio,", mScI)"))

        x_val = [];
        leg=[];
        for strain = 1:1:nbr_strains
            if nbr_strains<8
                colour_data = strcat(colour(strain)," o");
            else
                colour_data = strcat(colour(1)," o");
            end
            leg=[leg,Pil_types(strain)];  

            type=Pil_types(strain);
            index_type=find([polar_loc_speed_motile_results_ch2{:,1}]==type);
            nbr_replicates = size(index_type,2);

            x_val = [x_val,strain];
            for rep = 1:1:nbr_replicates
                if ~isempty(polar_loc_speed_motile_results_ch2{index_type(rep),3})
                    plot(x_val(strain),polar_loc_speed_motile_results_ch2{index_type(rep),type_ratio_position(1)},colour_data,'MarkerSize',8,'Linewidth',1) % plots median polar loc ratio of the replicate
                end
            end
            mean_data = mean([polar_loc_speed_motile_results_ch2{index_type,type_ratio_position(1)}]);           
            plot([x_val(strain)-0.15 x_val(strain)+0.15],[mean_data mean_data],'k -','Linewidth',3) % plots mean polar loc ratio over all replicates  
            text(x_val(strain), 0.05, num2str(polar_loc_speed_motile_concat_ch2{strain,7}), 'HorizontalAlignment','center'); % plots number of tracks
            if plot_violin
                violin(x_val(strain), polar_loc_speed_motile_concat_ch2{strain,type_ratio_position(2)},'facealpha',0.42,'linewidth',0.5,'style',2,'side','right','scaling',scaling_violin_polLoc) % plots distribution of single-track values combined for all replicates
            end
        end

        plot([0 nbr_strains+2],[no_polLoc no_polLoc],'k --','Linewidth',1)
        text(0.03,no_polLoc+0.03,"rough localization threshold FimW",'FontSize',8) % this threshold should be checked again
        title(strcat("Polar localization ratio after ",tos," on surface"));

        graph_type = strcat('polLoc_ratio',addition,'_',type_ratio,'_mScI');
        if save_graphs
            saveas(gcf,strcat(save_dir,save_name,graph_type,'.jpg'));
            saveas(gcf,strcat(save_dir,'fig_files\',save_name,graph_type,'.fig'));
            saveas(gcf,strcat(save_dir,'svg_files\',save_name,graph_type,'.svg'));
        end
    end
end

%% Plot polar loc ratio vs speed channel 1 (typically mNG)
if plot_polLoc_speed
    [type_ratio_position] = type_ratio_position_function(type_ratio);
    
    y_speed = 0.5;
    y_polLoc = 2.5;

    for strain = 1:1:nbr_strains
        
        figure('units','normalized','outerposition',[0 0 1 1])
        axis([0 y_speed 0 y_polLoc])
        hold on
        ylabel(strcat("Polar Loc Mot Index (",type_ratio,", mNG)"))
        xlabel("Speed (�m/s)")
                       
        type=Pil_types(strain);
        index_type=find([polar_loc_speed_motile_results{:,1}]==type);
        nbr_replicates = size(index_type,2);
        
        if rep_colour
            for rep = 1:1:nbr_replicates
                colour_reps = ["b","g","m","y","c","r"];
                if nbr_replicates<7
                    marker_rep = strcat(colour_reps(rep)," o");
                else
                    marker_rep = "k o";
                    disp(strcat("WARNING: Too many replicates. Can't plot replicate-specific colours for strain ",type))
                end
                if ~isempty(polar_loc_speed_motile_results{index_type(rep),3})
                    plot([polar_loc_speed_motile_results{index_type(rep),3}{:,5}],[polar_loc_speed_motile_results{index_type(rep),3}{:,type_ratio_position(3)}],marker_rep,'MarkerSize',5,'Linewidth',1) 
                end
            end
        else
            speeds = polar_loc_speed_motile_concat{strain, 3};
            polLocs = polar_loc_speed_motile_concat{strain, type_ratio_position(2)};
            plot(speeds,polLocs,"k o",'MarkerSize',5,'Linewidth',1) % plots polar localization motile index vs speed per track
        end
            
        plot([0 y_speed],[no_polLoc no_polLoc],'k --','Linewidth',1)
        text(y_speed-0.001,no_polLoc+0.03,"rough localization threshold FimW",'FontSize',8,'HorizontalAlignment','right') % this threshold should be checked again
        
        plot([no_move no_move],[0 y_polLoc],'k --','Linewidth',1)
        text(no_move+0.003,0.025,"rough no-move threshold",'FontSize',8,'rotation',-90,'HorizontalAlignment','right')
        
        title(strcat("Polar Loc vs Speed after ",tos," on surface (",type,", ",num2str(nbr_replicates)," reps, ",num2str(polar_loc_speed_motile_concat{strain,7})," tracks)"),'Interpreter','none');
        
        graph_type = strcat('polLoc_vs_speed',addition,'_',num2str(sscanf(type,'%i')),'_',type_ratio,'_mNG');
        if save_graphs
            saveas(gcf,strcat(save_dir,save_name,graph_type,'.jpg'));
            saveas(gcf,strcat(save_dir,'fig_files\',save_name,graph_type,'.fig'));
            saveas(gcf,strcat(save_dir,'svg_files\',save_name,graph_type,'.svg'));
        end
    end    
end

%% Plot polar loc ratio vs speed channel 2 (typically mScI)
if two_ch
    if plot_polLoc_speed
        [type_ratio_position] = type_ratio_position_function(type_ratio);

        for strain = 1:1:nbr_strains

            figure('units','normalized','outerposition',[0 0 1 1])
            axis([0 y_speed 0 y_polLoc])
            hold on
            ylabel(strcat("Polar Loc Mot Index (",type_ratio,", mScI)"))
            xlabel("Speed (�m/s)")

            type=Pil_types(strain);
            index_type=find([polar_loc_speed_motile_results_ch2{:,1}]==type);
            nbr_replicates = size(index_type,2);

            if rep_colour
                for rep = 1:1:nbr_replicates
                    colour_reps = ["b","g","m","y","c","r"];
                    if nbr_replicates<7
                        marker_rep = strcat(colour_reps(rep)," o");
                    else
                        marker_rep = "k o";
                        disp(strcat("WARNING: Too many replicates. Can't plot replicate-specific colours for strain ",type))
                    end
                    if ~isempty(polar_loc_speed_motile_results_ch2{index_type(rep),3})
                        plot([polar_loc_speed_motile_results_ch2{index_type(rep),3}{:,5}],[polar_loc_speed_motile_results_ch2{index_type(rep),3}{:,type_ratio_position(3)}],marker_rep,'MarkerSize',5,'Linewidth',1) 
                    end
                end
            else
                speeds = polar_loc_speed_motile_concat_ch2{strain, 3};
                polLocs = polar_loc_speed_motile_concat_ch2{strain, type_ratio_position(2)};
                plot(speeds,polLocs,"k o",'MarkerSize',5,'Linewidth',1) % plots polar localization motile index vs speed per track
            end

            plot([0 y_speed],[no_polLoc no_polLoc],'k --','Linewidth',1)
            text(y_speed-0.001,no_polLoc+0.04,"rough localization threshold FimW",'FontSize',8,'HorizontalAlignment','right') % this threshold should be checked again

            plot([no_move no_move],[0 y_polLoc],'k --','Linewidth',1)
            text(no_move+0.003,0.025,"rough no-move threshold",'FontSize',8,'rotation',-90,'HorizontalAlignment','right')

            title(strcat("Polar Loc vs Speed after ",tos," on surface (",type,", ",num2str(nbr_replicates)," reps, ",num2str(polar_loc_speed_motile_concat{strain,7})," tracks)"),'Interpreter','none');

            graph_type = strcat('polLoc_vs_speed,addition','_',num2str(sscanf(type,'%i')),'_',type_ratio,'_mScI');
            if save_graphs
                saveas(gcf,strcat(save_dir,save_name,graph_type,'.jpg'));
                saveas(gcf,strcat(save_dir,'fig_files\',save_name,graph_type,'.fig'));
                saveas(gcf,strcat(save_dir,'svg_files\',save_name,graph_type,'.svg'));
            end
        end    
    end
end

%% Plot polar loc ratio channel 1 vs channel 2
if two_ch
    if plot_polLoc_vs
        [type_ratio_position] = type_ratio_position_function(type_ratio);

        for strain = 1:1:nbr_strains

            figure('units','normalized','outerposition',[0 0 1 1])
            axis([0 y_polLoc 0 y_polLoc])
            hold on
            ylabel(strcat("Polar Loc Mot Index (",type_ratio,", mNG)"))
            xlabel(strcat("Polar Loc Mot Index (",type_ratio,", mScI)"))

            type=Pil_types(strain);
            index_type=find([polar_loc_speed_motile_results_ch2{:,1}]==type);
            nbr_replicates = size(index_type,2);

            if rep_colour
                for rep = 1:1:nbr_replicates
                    colour_reps = ["b","g","m","y","c","r"];
                    if nbr_replicates<7
                        marker_rep = strcat(colour_reps(rep)," o");
                    else
                        marker_rep = "k o";
                        disp(strcat("WARNING: Too many replicates. Can't plot replicate-specific colours for strain ",type))
                    end
                    if ~isempty(polar_loc_speed_motile_results_ch2{index_type(rep),3})
                        plot([polar_loc_speed_motile_results_ch2{index_type(rep),3}{:,type_ratio_position(3)}],[polar_loc_speed_motile_results{index_type(rep),3}{:,type_ratio_position(3)}],marker_rep,'MarkerSize',5,'Linewidth',1)
                    end
                end
            else
                polLocs_ch1 = polar_loc_speed_motile_concat{strain, type_ratio_position(2)};
                polLocs_ch2 = polar_loc_speed_motile_concat_ch2{strain, type_ratio_position(2)};
                plot(polLocs_ch2,polLocs_ch1,"k o",'MarkerSize',5,'Linewidth',1) % plots polar localization motile index vs speed per track
            end

            plot([0 y_polLoc],[no_polLoc no_polLoc],'k --','Linewidth',1)
            text(y_polLoc-0.003,no_polLoc+0.02,"rough localization threshold FimW",'FontSize',8,'HorizontalAlignment','right') % this threshold should be checked again
            
            plot([no_polLoc no_polLoc],[0 y_polLoc],'k --','Linewidth',1)
            text(no_polLoc+0.015,0.02,"rough localization threshold FimW",'FontSize',8,'rotation',-90,'HorizontalAlignment','right') % this threshold should be checked again

            title(strcat("Polar Loc mNG vs mScI after ",tos," on surface (",type,", ",num2str(nbr_replicates)," reps, ",num2str(polar_loc_speed_motile_concat{strain,7})," tracks)"),'Interpreter','none');

            graph_type = strcat('polLoc_ch1ch2',addition,'_',num2str(sscanf(type,'%i')),'_',type_ratio);
            if save_graphs
                saveas(gcf,strcat(save_dir,save_name,graph_type,'.jpg'));
                saveas(gcf,strcat(save_dir,'fig_files\',save_name,graph_type,'.fig'));
                saveas(gcf,strcat(save_dir,'svg_files\',save_name,graph_type,'.svg'));
            end
        end    
    end
end