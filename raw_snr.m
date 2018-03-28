%% Study-specific variables
study_dir = '/Users/Broca/Desktop/PARTICIPANT_DATA/TBS';
subjects = num2cell(dlmread([study_dir,'/scripts/tbs_subjects.txt']))';
sessions = {'PRE'};
func = 'uarest.nii';
gm = 'c1art_mean_uarest.nii';
wm = 'c2art_mean_uarest.nii';
csf = 'c3art_mean_uarest.nii';

%% Calculate SNR values and collate motion statistics
snr = zeros(length(subjects),4);
for i = 1:length(subjects)
    subject = num2str(subjects{i})
    
    for j = 1:length(sessions)
        session = sessions{j};
        
        % This struct contains the geometry for your output images
        g = spm_vol(fullfile(study_dir,subject,session,gm));  
        
        % Make binary mask from tissue masks
        G = spm_read_vols(g);
        W = spm_read_vols(spm_vol(fullfile(study_dir,subject,session,wm)));
        C = spm_read_vols(spm_vol(fullfile(study_dir,subject,session,csf)));
        M = G+W+C;M(M>0.5)=1;M(M<1)=0;G(G>0.5)=1;G(G<1)=0;
        g.fname = fullfile(study_dir,subject,session,'mask.nii');
        spm_write_vol(g,M);
        
        % Extract functional data and mask out-of-brain voxels
        V = spm_vol(fullfile(study_dir,subject,session,func));
        Y = spm_read_vols(V);
        Y(G~=1)=NaN;
        
        % SNR
        if j==1
            snr(i,1) = nanmean(Y(:))/nanstd(Y(:));
        elseif j==2
            snr(i,3) = nanmean(Y(:))/nanstd(Y(:));
        end
        
        % Slice SNR
        slice = zeros(g.dim(3),1);
        for k = 1:g.dim(3)
            tmp = Y(:,:,k);
            slice(k,1) = nanmean(nanmean(tmp))/nanstd(nanstd(tmp,0,2));
            slice(k,1) = nanmean(nanmean(Y(:,:,k),2))/nanstd(nanstd(Y(:,:,k),0,2)); 
        end
        
        if j==1
            snr(i,2) = nanmean(slice);
        elseif j==2
            snr(i,4) = nanmean(slice);
        end
             
    end
end
%load() for your matfile - R is variable
%set idx = find(any(R==1,2)) to id vols to cut