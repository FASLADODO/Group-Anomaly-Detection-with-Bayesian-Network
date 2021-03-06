% (C) Copyright 2011, Liang Xiong (lxiong[at]cs[dot]cmu[dot]edu)
% 
% This piece of software is free for research purposes. 
% We hope it is helpful but do not privide any warranty.
% If you encountered any problems please contact the author.

function [score] = ScoreVar(self, X, group_id)
% [score] = ScoreVar(self, X, group_id)
% score groups using the variational distribution of z
% anomalies have lower scores

pi = self.pi;
chi = self.chi;

[K,T] = size(chi);
uid = unique(group_id);
group_id = EncodeInt(group_id, uid);
M = double(max(group_id));

lnpdf = GMM([], self.mus, self.sigmas).GetProb(X, true);
[gama, phi] = self.InferVar(lnpdf, group_id, struct('max_iter', 100, 'verbose', false));

score = 0;
tmp = zeros(M, T);
nsample = 100;
for ind = 1:nsample
    zs = randm(phi);
    group_z_hist = accumarray([group_id(:) zs(:)], 1, [M, K]);
    for t = 1:T
        tmp(:, t) = mnpdfex(group_z_hist, chi(:, t), true);
    end
    score = score + logmulexp(tmp, log(pi + eps(0.0)));
end
score = score/nsample;

tmp = nan(max(uid), 1);
tmp(uid) = score;
score = tmp;
