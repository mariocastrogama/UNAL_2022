clc;
clear;
close all;
fclose all;
format long g;

% Input dialog
prompt={'File of Measurements','File of Results','Enter the E12:','Enter the E13:'};
name='Solve a water quality problem';
numlines = [1 50; 1 50; 1 20; 1 20];
defaultanswer={'riverlake_measurements.dat','results.dat','2.0','3.0'};
optionsinput.Resize='on';
optionsinput.WindowStyle='normal';
optionsinput.Interpreter='tex';
answer=inputdlg(prompt, name, numlines, defaultanswer, optionsinput);


if ~isempty(answer);
  %Initial Condition
  Co    = zeros(3,1);
  Co(3) = 100;

  % Parameters
  E = [str2double(answer{3}), str2double(answer{4})];
  %optionsode = odeset('AbsTol',1e-6,'InitialStep',0.1,'MaxStep',0.2);

  [t,C]=ode45(@(t,y) three_tanks(t,y,E),[0 20],Co);


  % load measured values
  data_set = load(answer{1});
  tm = data_set(:,1);
  Cm = data_set(:,2:4);

  % Interpolate only where required
  Cp = interp1(t,C,tm);

  % Error measurement
  err = Cm - Cp;
  abias = sum(sum(abs(err)));
  SSR = sum(sum(err.*err));

  h1 = figure(1);
  set(h1,'units','normalized')
  set(h1,'outerposition',[0 0 1 1]);
  text_size = 13;
  text_weight = 'Bold';
  for ii = 1:3;
    subplot(3,1,ii)
    plot( t, C(:,ii),'b--','linewidth',3); hold on;
    plot(tm,Cm(:,ii),'ro','linewidth',2,'Markerfacecolor','g'); hold off;
    set(gca,'FontName','Arial');
    set(gca,'FontSize',text_size);
    set(gca,'FontWeight','Bold');
    if ii ==1;
      title(['Concentrations for E_{12} : ',sprintf('%2.4g',E(1)),',  E_{13} : ',sprintf('%2.4g',E(2)),'      SSR : ',sprintf('%2.5g',SSR)]);
    end
    ylabel(['C_',num2str(ii),' [mg/l]']);
  end
  
  xlabel('Time [day]');
  
  %% Write output file with results
  fid = fopen(answer{2},'w');
  fprintf(fid,'%s\n','River and stratified lake problem');
  fprintf(fid,'%s\n','Solution with:');
  fprintf(fid,'%s\n','  E12     E13');
  fprintf(fid,'%.3f\t %.3f\n',E');
  fprintf(fid,'%s\n','');
  fprintf(fid,'%s\n','Measured Data');
  fprintf(fid,'%s\n',' Day    C1    C2    C3');
  fprintf(fid,'%0.2d\t %.3f\t %.3f\t %.3f\n',data_set');
  fprintf(fid,'%s\n','---------------------------');
  fprintf(fid,'%s\n','');
  fprintf(fid,'%s\n','Predicted Data');
  fprintf(fid,'%s\n',' Day    C1    C2    C3');
  fprintf(fid,'%0.2d\t %.3f\t %.3f\t %.3f\n',[data_set(:,1), Cp]');
  fprintf(fid,'%s\n','---------------------------');
  fprintf(fid,'%s\n','');
  fprintf(fid,'%s\n','Squares of Residuals');
  fprintf(fid,'%s\n',' Day    C1    C2    C3');
  fprintf(fid,'%0.2d\t %.3f\t %.3f\t %.3f\n',[data_set(:,1), err.^2]');
  fprintf(fid,'%s\n','   ------------------------');
  fprintf(fid,'%10.3f\t %.3f\t %.3f\n',[sum(err.^2)]');
  fprintf(fid,'%26.3f\n',SSR);
  fclose(fid);
end