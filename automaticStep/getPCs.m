function [score1, score2] = getPCs(wv, PCs)

score1 = zeros(size(wv,1), size(wv,2));
score2 = zeros(size(wv,1), size(wv,2));

for ch = 1 : size(wv,2)
    if size(wv,1) > 1
        score1(:,ch) = squeeze(wv(:,ch,:)) * squeeze(PCs(ch,:,1))';
        score2(:,ch) = squeeze(wv(:,ch,:)) * squeeze(PCs(ch,:,2))';    
    elseif size(wv,1) == 1
        score1(:,ch) = squeeze(wv(:,ch,:))' * squeeze(PCs(ch,:,1))';
        score2(:,ch) = squeeze(wv(:,ch,:))' * squeeze(PCs(ch,:,2))';    
    end
end