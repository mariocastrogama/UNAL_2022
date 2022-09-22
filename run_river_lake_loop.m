% This example runs a water quality model of a river, and a lake with two 
% stratified layers. 
% It is presented as a zero dimensional mass balance of contaminant in the 
% river which flows to the lake

clc;
clear;
format long g;

% Input dialog
prompt={'File of Measurements','File of Results','Number of simulations','Enter the Range of E12:','Enter the Range of E13:'};
name='Solve a water quality problem';
numlines = [1 50; 1 50; 1 30; 1 30; 1 30];
defaultanswer={'riverlake_measurements.dat','riverlake_results.dat','500','[0.0, 6.0]','[1.0, 4.0]'};
optionsinput.Resize='on';
optionsinput.WindowStyle='normal';
optionsinput.Interpreter='tex';
answer=inputdlg(prompt, name, numlines, defaultanswer, optionsinput);


if ~isempty(answer)

  % Number of Parameters
  nparameters = 2;
  % Number of Objectives
  nobjectives = 2;

  % load measured values
  data_set = load('riverlake_measurements.dat');
  tm = data_set(:,1);
  Cm = data_set(:,2:4);

  %Initial Condition
  Co    = zeros(3,1);
  Co(3) = 100;
  options = odeset('AbsTol',1e-6);%,'InitialStep',0.1,'MaxStep',0.1);

  % Monte-Carlo Simulation
  nsim = str2double(answer{3});
  parameters = zeros(nsim,nparameters);
  objectives = zeros(nsim,nobjectives);
  SSR = 1/eps;
  SSRmin = 200;
  sim = 0;
  E12 = str2num(answer{4});
  E13 = str2num(answer{5});
  w1 = waitbar(0,'Please wait...');
  while (sim < nsim)
    % Parameters
    E = [E12(1)+(E12(2)-E12(1))*rand, E13(1)+(E13(2)-E13(1))*rand];

    % Evaluate function
    [t,C] = ode45(@(t,y) three_tanks(t,y,E),[0 20],Co);

    % Interpolate only where measurements are avaialble
    Cp = interp1(t,C,tm);
    err = Cm-Cp; % error/Residuals
    abias = sum(sum(abs(err))); % abias
    SSR = sum(sum(err.*err)); % Sum of Squared Errors
    if (SSR < SSRmin)
      sim = sim + 1;
      parameters(sim,:) = E;
      objectives(sim,:) = [SSR, abias];
      waitbar(sim/nsim,w1);
    end
  end
  close(w1);

  %% Figure 1. Simulated (Predicted) and Measured (Observed) results

  text_size = 13;
  text_weight = 'Bold';

  [objectives_min, xopt] = min(objectives);
  Eopt = parameters(xopt(1),:);
  [topt,Copt]=ode45(@(t,y) three_tanks(t,y,Eopt),[0 20],Co);
  Cp = interp1(topt,Copt,tm);
  h1 = figure(1);
  set(h1,'Color',[1.0 1.0 1.0]);
  set(h1,'units','normalized')
  set(h1,'outerposition',[0 0 1 1]);%set(h1,'Position',[50 100 700 600]);
  set(h1,'Name',' River and Stratified Lake, Concentration Time Series');

  for ii = 1:3
    subplot(3,1,ii)
    plot(topt, Copt(:,ii),'b--','linewidth',3); hold on;
    plot(  tm,   Cm(:,ii),'ro','linewidth',2,'Markerfacecolor','g'); hold off;
    set(gca,'FontName','Arial');
    set(gca,'FontSize',text_size);
    set(gca,'FontWeight','Bold')
    ylabel(['C_',num2str(ii),' [mg/l]']);
    if (ii == 1)
      title(['Concentrations for E_{12} : ',sprintf('%2.4g',Eopt(1)),',  E_{13} : ',sprintf('%2.4g',Eopt(2)),'      SSR : ',sprintf('%2.5g',objectives_min(1))]);
    end
  end
  xlabel('Time [day]');
  legend('Predicted','Measured');

  %% Figure 2. Parameter space
  parameters_names = {'E_{12}','E_{13}'};
  objectives_names = {'SSR','ABIAS'};


  h2=figure(2);
  set(h2,'Color',[1.0 1.0 1.0]);
  set(h2,'units','normalized')
  set(h2,'outerposition',[0 0 1 1]);%set(h2,'Position',[800 100 700 600]);
  set(h2,'Name',' River and Stratified Lake, Parameter Space');
  kk = 0;
  for ii = 1:size(objectives,2)
    for jj = 1:size(parameters,2)
      kk = kk +1;
      subplot(2,2,kk)
      plot(parameters(:,jj),objectives(:,ii),'b.'); hold on;
      plot(parameters(xopt(ii),jj),objectives(xopt(ii),ii),'rs','Markerfacecolor','y'); hold off;
      legend('Samples',['Optimum, ',parameters_names{jj},': ',sprintf('%1.4g',parameters(xopt(ii),jj))]);

      set(gca,'FontName','Arial');
      set(gca,'FontSize',text_size);
      set(gca,'FontWeight','Bold');
      xlabel(parameters_names{jj});
      ylabel(objectives_names{ii});
    end
  end

  %% Figure 3. Objective Space
  % Find the limits of your dataset (to define grid)
  parameters_max = max(parameters);
  parameters_min = min(parameters);
  objectives_max = max(objectives);
  objectives_min = min(objectives);

  % Order with respect to parameters
  [parameters2,parameters_order] = sortrows(parameters);

  % Find the new position of the objectives after reordering data
  xopt1 = find(objectives(:,1) == objectives_min(1));
  xopt1_order = find(parameters_order == xopt1);
  xopt2 = find(objectives(:,2) == objectives_min(2));
  xopt2_order = find(parameters_order == xopt2);

  % Create the grid of the objective space
  [parameters_grid1, parameters_grid2] = meshgrid(linspace(E12(1),E12(2),100),linspace(E13(1),E13(2),100)); % [param1,param2] = meshgrid(pars_min(1):.1:pars_max(1), pars_min(2):.4:pars_max(2));
  objectives_grid1 = griddata(parameters(:,1), parameters(:,2), objectives(:,1), parameters_grid1, parameters_grid2);
  objectives_grid2 = griddata(parameters(:,1), parameters(:,2), objectives(:,2), parameters_grid1, parameters_grid2);

  % Plot data of Objective space
  h3 = figure(3);
  set(gcf,'Color',[1.0 1.0 1.0]);
  set(h3,'units','normalized')
  set(h3,'outerposition',[0 0 1 1]);
  set(h3,'Name',' River and Stratified Lake, Objective Space');
  % set(gcf,'Position',[800 100 700 600]);

  subplot(1,2,1)
  plot3(parameters2(:,1),     parameters2(:,2),     objectives(parameters_order,1),'.'); hold on;
  plot3(parameters2(xopt1_order,1), parameters2(xopt1_order,2), objectives_min(1),'rs','Markerfacecolor','y'); hold on;
  surfc(parameters_grid1, parameters_grid2, objectives_grid1); hold off;
  shading flat;
  colorbar('NorthOutside');
  grid on;
  set(gca,'FontName','Arial');
  set(gca,'FontSize',text_size);
  set(gca,'FontWeight','Bold');
  axis square;
  view(-60,30);
  xlabel(parameters_names{1});
  ylabel(parameters_names{2});
  zlabel(objectives_names{1});

  subplot(1,2,2)
  plot3(parameters2(:,1),     parameters2(:,2),     objectives(parameters_order,2),'.'); hold on;
  plot3(parameters2(xopt2_order,1), parameters2(xopt2_order,2), objectives_min(2),'rs','Markerfacecolor','y'); hold on;
  surfc(parameters_grid1, parameters_grid2, objectives_grid2); hold off;
  shading flat;
  colorbar('NorthOutside');
  grid on;
  set(gca,'FontName','Arial');
  set(gca,'FontSize',text_size);
  set(gca,'FontWeight','Bold');
  axis square;
  view(-60,30);
  xlabel(parameters_names{1});
  ylabel(parameters_names{2});
  zlabel(objectives_names{2});
  %% Write output file with results
  fid = fopen(answer{2},'w');
  fprintf(fid,'%s\n','River and stratified lake problem Calibration');
  fprintf(fid,'%s\n','Optimal Solution:');
  fprintf(fid,'%s\n','  E12     E13');
  fprintf(fid,'%.3f\t %.3f\n',Eopt');
  fprintf(fid,'%s\n','');
  fprintf(fid,'%s\n','Measured Data');
  fprintf(fid,'%s\n',' Day    C1    C2    C3');
  fprintf(fid,'%0.2d\t %.3f\t %.3f\t %.3f\n',data_set');
  fprintf(fid,'%s\n','---------------------------');
  fprintf(fid,'%s\n','');
  fprintf(fid,'%s\n','Optimal Solution');
  fprintf(fid,'%s\n',' Day    C1    C2    C3');
  fprintf(fid,'%0.2d\t %.3f\t %.3f\t %.3f\n',[tm, Cp]');
  fprintf(fid,'%s\n','---------------------------');
  fprintf(fid,'%s\n','');
  fprintf(fid,'%s\n','Squares of Residuals');
  fprintf(fid,'%s\n',' Day    C1    C2    C3');
  fprintf(fid,'%0.2d\t %.3f\t %.3f\t %.3f\n',[tm, (Cm-Cp).^2]');
  fprintf(fid,'%s\n','   ------------------------');
  fprintf(fid,'%10.3f\t %.3f\t %.3f\n',sum((Cm-Cp).^2)');
  fprintf(fid,'%26.3f\n',sum(sum((Cm-Cp).^2)));
  fclose(fid);
end