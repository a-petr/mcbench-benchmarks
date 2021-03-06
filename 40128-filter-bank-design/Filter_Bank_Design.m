




function [h,f,distortion,total_aliasing]=Filter_Bank_Design(nk,ratio,transition_factor,N,ro,iteration_max,function_evaluation_max,cost_function_weight,initial_filters)
%
%
% [h,f,distortion,total_aliasing]=Filter_Bank_Design(nk,ratio,transition_factor,N,ro,iteration_max,function_evaluation_max,cost_function_weight,initial_filters)
% This function can be used to design all types of filter banks (critically/over sampled uniform       
% filter banks and non-uniform filter banks) using optimization based on the algorithm presented in [1]. 
%
% Problem Description: Design M analysis and synthesis FIR filters so that
% the analysis filters satisfy some frequency specifications and the filter bank
% (almost) meets the perfect reconstruction (PR) conditions. Both goals are achieved by minimizing
% the following performance index:
%
% J=w1*(PR error)+w2*(Frequency Specification error)
% where w1 and w2 are optional weights
%
% Matlab Requirements: To run this function, your Matlab needs to have the following toolboxes:
% 1- signal processing toolbox, 2- optimization toolbox, 3- filter design toolbox
%
% 
% ---------------------------------------------------------------
% Function inputs:
% 1- nk: an M-element vector which includes the set of sampling rates.
% 2- ratio: the frequency ratio occupied by each individual analysis filter. 
%    e.g. 0.5 means half of the whole normalized frequency spectrum is occupied by the filter. 
% 3- transition_factor: a vector with the same length as the "ratio" vector, and it is used to define 
%    passband & stopband cut-off frequencies. Smaller transition_factor results in sharper transition band.
%    Note: All elements in the "transition_factor" vector must be less than half of the smallest element in the "ratio" vector.
%    
%    Using the "ratio" vector and the "transition_factor" vector, 
%    the analysis filters' frequency specifications are given as:
%    First filter- lowpass filter with the following normalized cut-off frequencies:
%               a) passband cut-off frequency: [ratio(1)-transition_factor(1)]*pi
%               b) stopband cut-off frequency: [ratio(1)+transition_factor(1)]*pi
%    Last filter-  highpass filer with the following cut-off frequencies:
%               a) passband cut-off frequency: pi-[ratio(end)-transition_factor(end)]*pi
%               b) stopband cut-off frequency: pi-[ratio(end)+transition_factor(end)]*pi
%    Other filers- bandpass filters with the following cut-off frequencies:
%               a) first stopband cut-off frequency: [sum(ratio(1:i-1))-transition_factor(i)]*pi
%               b) first passband cut-off frequency: [sum(ratio(1:i-1))+transition_factor(i)]*pi              
%               c) second passband cut-off frequency:[sum(ratio(1:i-1))+ratio(i)-transition_factor(i)]*pi
%               d) second stopband cut-off frequency:[sum(ratio(1:i-1))+ratio(i)+transition_factor(i)]*pi
%
% 4- N: filter length which is the same for both FIR analysis and synthesis filters.
% 5- ro: frequency resolution, i.e. "ro" points with a uniform distribution from 0 to pi (positive part of the
%    normalized frequencies) are used to compute the frequency response of the analysis filters(see Eq.(29) in [1]).
% 6- iteration_max: Maximum number of iterations allowed by the optimization algorithm (see "optimset" in Matlab). 
% 7- function_evaluation_max: Maximum number of function evaluations allowed by the optimization algorithm (see "optimset" in Matlab).
% 8- cost_function_weight: a 2-element vector consisting of optional weights to compute cost function. 
%    The first element is the weight for PR error (w1 in the performance
%    index defined above) and the second element is the weight for frequency specification error (w2)
% 9- initial_filters: Initial analysis filters for the optimization algorithm which can be defined by user or automatically
%    generated by the function (set the parameter to "[]")
% ----------------------------------------------------------------
% Function outputs:
% 1- h: is a matrix in which each row is corresponding to one of the analysis filters
%    e.g. if the sampling set (nk) is [2 4 4], the first row of h contains the coefficients
%    of the analysis filter on the branch with subsampling of 2. 
% 2- f: is a matrix in which each row is corresponding to one of the synthesis filters
% 3- distortion: The final distortion (in dB) after the convergence (See Eq.(2) in [1])
% 4- total_aliasing: Total aliasing (in dB) after the convergence (See Eq.(2) in [1]) 
%    Note: "distortion" and "total_aliasing" are calculated for 512
%    frequencies distributed uniformly from 0 to pi (normalized frequency)
% ----------------------------------------------------------------
%
%
% Note: Since the cost function is not convex (see Eq.(28) in [1]), the
%       global convergence is not guaranteed. If the algorithm doesn't converge to
%       a desired response, one can increase the filter order (N) at the cost of increasing 
%       computational complexity and convergence time, or test different
%       "cost_function_weight" vectors.  
%
% Example 1: Critically Sampled Uniform Filter Bank - Sampling set is {2,2}
% [h,f,distortion,total_aliasing]=Filter_Bank_Design([2 2],[0.5 0.5],[0.15 0.15],14,32,100,20000,[20 1],[]);
%
% Example 2: Over Sampled Uniform Filter Bank - Sampling set is {2,2,2}
% [h,f,distortion,total_aliasing]=Filter_Bank_Design([2 2 2],[1/3 1/3 1/3],[0.08 0.08 0.08],16,32,100,20000,[1 1],[]);
%
% Example 3: Non-Uniform Filter Bank - Sampling set is {2,4,4}
% [h,f,distortion,total_aliasing]=Filter_Bank_Design([2 4 4],[0.5 0.25 0.25],[0.1 0.1 0.1],24,64,100,20000,[10 1],[]);
%
%
% [1] Moazzen, I., Agathoklis, P., "A General Approach for Filter Bank
% Design Using Optimization", IET Journal on Signal Processing, 2012 (submitted).
%
%
% Written By:   Iman Moazzen
%               Under supervision of Prof. Panajotis Agathoklis
%               Dept. of Electrical Engineering
%               University of Victoria
%
% To find other Matlab functions about filter design,
% please visit http://www.ece.uvic.ca/~imanmoaz/index_files/index1.htm




global Beta Sigma_dictionary M N K R gamma_cof cost_function_weight optional_delay
% clc

K=length(nk);
M=Find_LCM(nk);
types_dictionay=cell(1,K);
cutoff_frequencies_dictionary=cell(1,length(K));
optional_delay=0;

for i=1:K
    if i==1
    types_dictionay{i}='lowpass';
    elseif i==K
    types_dictionay{i}='highpass';
    else
    types_dictionay{i}='bandpass';
    end
end



f_cut1_filter_first=(ratio(1)-transition_factor(1))*pi;
f_cut2_filter_first=(ratio(1)+transition_factor(1))*pi;

f_cut1_filter_end=(1-ratio(end)-transition_factor(end))*pi;
f_cut2_filter_end=(1-ratio(end)+transition_factor(end))*pi;


cutoff_frequencies_dictionary{1}=[f_cut1_filter_first f_cut2_filter_first];
cutoff_frequencies_dictionary{K}=[f_cut1_filter_end f_cut2_filter_end];


%%%%%%%%%% initial desing %%%%%%%%%%%% 
    for i=2:K-1
    f_cut1_filter_middle=[sum(ratio(1:i-1))-transition_factor(i)]*pi;
    f_cut2_filter_middle=[sum(ratio(1:i-1))+transition_factor(i)]*pi;
    f_cut3_filter_middle=[sum(ratio(1:i-1))+ratio(i)-transition_factor(i)]*pi;
    f_cut4_filter_middle=[sum(ratio(1:i-1))+ratio(i)+transition_factor(i)]*pi;  
    hh(i,:)=firpm(N-1,[0 f_cut1_filter_middle f_cut2_filter_middle f_cut3_filter_middle f_cut4_filter_middle pi]/pi,[0 0 1 1 0 0]);
    cutoff_frequencies_dictionary{i}=[f_cut1_filter_middle f_cut2_filter_middle f_cut3_filter_middle f_cut4_filter_middle];
    end
    hh(1,:)=firpm(N-1,[0 f_cut1_filter_first f_cut2_filter_first pi]/pi,[1 1 0 0]);
    temp_hh_end=firpm(N-1,[0 f_cut1_filter_end f_cut2_filter_end pi]/pi,[0 0 1 1]);
    hh(K,:)=temp_hh_end(1:N);
    clc

    if isempty(initial_filters)==1
       x0=hh;
    else
       x0=initial_filters;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Beta=Beta_dictionary(M,nk);

for index=0:M-1
     temp_Sigma=Sigma_i(index,M,N);
     Sigma_dictionary(index+1,:)=temp_Sigma;
end



w_dictonary=linspace(0,pi,ro);
gamma_cof=cell(K,1);
w_cof=cell(K,1);
for i=1:K
[temp_gamma_cof temp_w_cof]=gamma_generator(types_dictionay{i},cutoff_frequencies_dictionary{i},w_dictonary);
gamma_cof{i}=temp_gamma_cof;
w_cof{i}=temp_w_cof;
end


R=cell(1,K);
for i=1:K
    clear temp_w temp_R1 temp_R2
    temp_w=w_cof{i};
    for j=1:length(temp_w)
    temp_R1=R_Matrix_Formation(temp_w(j),N);
    temp_R2(:,:,j)=temp_R1;
    end
    R{i}=temp_R2;
end


options = optimset('Display','iter','MaxIter',iteration_max,'MaxFunEvals',function_evaluation_max);
[x,fval] = fminunc(@Filter_Bank_Design_In_General_Case,x0,options);
h=x;

%%%%%%%%%%%%%%%%%%%%% showing the performance %%%%%%%%%%%%%%%%%%


%%%%%%%%% initial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=A_gerenator(x0,Beta,Sigma_dictionary,M);
[m1,n1]=size(A);
b=zeros(m1,1);
b(N+optional_delay)=1;
Q=lscov(A,b);
error_pr=norm(A*Q-b);


[m2,n2]=size(Q);
temp_new=0;
for k=1:m2/N
    f(k,:)=Q(1+temp_new:N+temp_new)';
    temp_new=temp_new+N;
end
f=real(f);

tt=A*Q;
distortion_initial=tt(1:2*N-1);
total_aliasing_initial=tt(2*N:end);

[Distortion,W]=freqz(distortion_initial);
[Total_Aliasing,W]=freqz(total_aliasing_initial);

figure,

subplot(2,2,1)
plot(W,20*log10(abs(Distortion)),'r','linewidth',2);
xlim([0 pi])
title('Initial Distortion','fontsize',12)
xlabel('Normalized Frequency','fontsize',12)
ylabel('Amplitude','fontsize',12)

subplot(2,2,3),
plot(W,20*log10(abs(Total_Aliasing)),'r','linewidth',2);
xlim([0 pi])
title('Initial Aliasing','fontsize',12)
xlabel('Normalized Frequency','fontsize',12)
ylabel('Amplitude','fontsize',12)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%% final %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=A_gerenator(x,Beta,Sigma_dictionary,M);
[m1,n1]=size(A);
b=zeros(m1,1);
b(N+optional_delay)=1;
Q=lscov(A,b);



[m2,n2]=size(Q);
temp_new=0;
for k=1:m2/N
    f(k,:)=Q(1+temp_new:N+temp_new)';
    temp_new=temp_new+N;
end
f=real(f);

tt=A*Q;
distortion_temp=tt(1:2*N-1);
total_aliasing_temp=tt(2*N:end);

[Distortion,W]=freqz(distortion_temp);
[Total_Aliasing,W]=freqz(total_aliasing_temp);

distortion=20*log10(abs(abs(Distortion)-1));
total_aliasing=20*log10(abs(Total_Aliasing));

subplot(2,2,2)
plot(W,20*log10(abs(abs(Distortion)-1)),'b','linewidth',2);
xlim([0 pi])
title('Final Distortion','fontsize',12)
xlabel('Normalized Frequency','fontsize',12)
ylabel('Amplitude','fontsize',12)

subplot(2,2,4),
plot(W,20*log10(abs(Total_Aliasing)),'b','linewidth',2);
xlim([0 pi])
title('Final Aliasing','fontsize',12)
xlabel('Normalized Frequency','fontsize',12)
ylabel('Amplitude','fontsize',12)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%% filter %%%%%%%%%%%
figure,

color_cell=cell(1,K);


for i=1:K 
    if i==1
        color_cell{i}='b'; 
    elseif i==2
        color_cell{i}='r';    
    elseif i==3
        color_cell{i}='g';
    elseif i==4
        color_cell{i}='k';
    elseif i==5
        color_cell{i}='c';
    elseif i==6
        color_cell{i}='y';
    elseif i==7
        color_cell{i}='m';
    else
        color_cell{i}='b'; 
    end

[H,W]=freqz(x(i,:),1);
[F,W]=freqz(f(i,:),1);
subplot(1,2,1)
plot(W,20*log10(abs(H)),color_cell{i},'linewidth',2)
xlim([0 pi])
hold on
title('Final Analysis Filters','fontsize',12)
xlabel('Normalized Frequency','fontsize',12)
ylabel('Amplitude Response(dB)','fontsize',12)
subplot(1,2,2)
plot(W,20*log10(abs(F)),color_cell{i},'linewidth',2)
xlim([0 pi])
hold on
title('Final Synthesis Filters','fontsize',12)
xlabel('Normalized Frequency','fontsize',12)
ylabel('Amplitude Response(dB)','fontsize',12)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear global Beta Sigma_dictionary M N K R gamma_cof cost_function_weight optional_delay