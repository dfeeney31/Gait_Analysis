%%%% Calculate the top 10 power and angles at each joint %%%%
%Open up a subjects kinematics and kinetics file and run this. Output has
%the data to paste into the excel workbook. 
fr = 1000; %Set frequency

%Calculate peaks in ankle hip and knee power
Ankle_pks = findpeaks(LAnklePower{1,1}(:,1),'MinPeakDistance',100);
Knee_pks = findpeaks(LKneePower{1,1}(:,1),'MinPeakDistance',100);
Hip_pks = findpeaks(LHipPower{1,1}(:,1),'MinPeakDistance',100);
%Calculate AVG and SD for joint powers
Avg_ankle_pw = mean(Ankle_pks); SDanklePW = std(Ankle_pks);
Avg_Knee_pw = mean(Knee_pks); SDKneePW = std(Knee_pks);
Avg_Hip_pw = mean(Hip_pks); SDHipPW = std(Hip_pks);

%Calcualte peaks in ankle, hip, and knee moment
AnkleMom_pks = findpeaks(LAnkleMoment{1,1}(:,1),'MinPeakDistance',100);
KneeMom_pks = findpeaks(LKneeMoment{1,1}(:,1),'MinPeakDistance',100);
HipMom_pks = findpeaks(LHipMoment{1,1}(:,1),'MinPeakDistance',100);
%Calculate AVG and SD for joint MOMENTS
Avg_ankle_mom = mean(AnkleMom_pks); SDanklePW = std(AnkleMom_pks);
Avg_Knee_mom = mean(KneeMom_pks); SDKneePW = std(KneeMom_pks);
Avg_Hip_mom = mean(HipMom_pks); SDHipPW = std(HipMom_pks);

%%%% For step frequency and length %%%%
[b,a] = butter(4,6/1000,'low'); %Only enable if you want to filter
FP2_filt = filtfilt(b,a,FP2{1,1}(:,3)); 
FP2_filt(FP2_filt < 0) = 0;
FP1_filt = filtfilt(b,a,FP1{1,1}(:,3));
FP1_filt(FP1_filt < 0) = 0;

%Find the zeros of the force signals
zeros1 = find(~FP1_filt);
zeros2 = find(~FP2_filt);
%Find indices when difference greater than 2
indicesL = find(diff(zeros1)>5);
indicesR = find(diff(zeros2)>5);
%Use indices to index into original zeros data
LHS = zeros1(indicesL); 
RHS = zeros2(indicesR); 
LTO = zeros1(indicesL+1);
RTO = zeros2(indicesR+1);

%output = horzcat(Avg_ankle_pw,Avg_Knee_pw,Avg_Hip_pw,Avg_ankle_mom, Avg_Knee_mom,Avg_Hip_mom);
% Remove false positive heel strikes 
Llength = length(LHS)-5;
Rlength = length(RHS)-5;

for i = 1:19
    if LHS(i+1) - LHS(i) < 500
        LHS(i) = [];
        LTO(i) = [];
    end
end
for ii = 1:19
    if RHS(ii+1) - RHS(ii) < 500
            RHS(ii) = [];
            RTO(ii) = [];
    end
end

plot(FP2_filt)
hold on
%plot(FP1_filt,'Color','red')
for mn = 1:length(RHS)
    line([RHS(mn) RHS(mn)], get(gca, 'ylim'),'color','k')
end
% Calculate step and stride frequency
lastR_time = RHS(end)/1000;
lastL_time = LHS(end)/1000;
RStepfrq = length(RHS)/lastR_time; LStepfrq = length(LHS)/lastL_time;
Step_Frq = (RStepfrq + LStepfrq)/ 2;
StrideFrq = length(RHS)/lastR_time;

% Calculate contact time
ContactR = RTO - RHS; avgconR = mean(ContactR); SDcr = std(ContactR); 
ContactL = LTO - LHS; avgconL = mean(ContactL); SDcl = std(ContactL);

R_contact_time = avgconR/fr;
L_contact_time = avgconL/fr;

output = horzcat(Avg_ankle_pw,Avg_Knee_pw,Avg_Hip_pw,Avg_ankle_mom, Avg_Knee_mom,Avg_Hip_mom, Step_Frq, StrideFrq, R_contact_time, L_contact_time);
