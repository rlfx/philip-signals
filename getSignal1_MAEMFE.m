clc;clear all;close all;
unit = 0.0001 ;
scal = 0.2 ;

load('data_of_EURUSD_15m_turtlized.mat');
target_signal = SIGNAL1_PNL ;

n_signal = length( target_signal );


%% get trade interval 
trade_interval = cell(0,1);
interval_start = 1 ;
interval_end   = 1 ;
in_interval = 0 ;
for i_signal = 2 : n_signal
        
    if target_signal(i_signal) ~= target_signal(i_signal-1)
        in_interval = 1 ;
        interval_end = i_signal-1 ;
    else
        if in_interval == 1
            trade_interval{end+1} = [interval_start, i_signal-1];
            in_interval = 0 ;
        end
        interval_start = i_signal ;
    end
    
    if interval_end < interval_start
        interval_end =  interval_start ;
    end
    
end
    
%% get MAE / MFE
n_trade = length( trade_interval );
mae = zeros(1, n_trade); mfe = zeros(1, n_trade);
profitloss = zeros(1, n_trade);
profitloss_cum = zeros(1,n_trade);
ltmfe = zeros(0,1);
ltmfe_trade = zeros(0,1);
for i_trade = 1 : n_trade
    
    this_interval = trade_interval{i_trade};
    init_pnl = target_signal(this_interval(1));
    lv0_mae = init_pnl ; lv1_mfe = init_pnl ; lv1_mae = lv0_mae ;
    for i = this_interval(1)+1 : 1 : this_interval(2)
        if target_signal(i) > lv1_mfe
            lv1_mfe = target_signal(i);
            if lv0_mae < lv1_mae
                lv1_mae = lv0_mae ;
            end
        end
        if target_signal(i) < lv0_mae
            lv0_mae = target_signal(i) ;
        end
    end
    mae(i_trade) = init_pnl - lv1_mae ;
    mfe(i_trade) = lv1_mfe - init_pnl ;
    profitloss(i_trade) = target_signal(this_interval(2)) - init_pnl ;
    if i_trade > 1 
    profitloss_cum(i_trade) = profitloss_cum(i_trade-1) + profitloss(i_trade);
    else
    profitloss_cum(i_trade) = profitloss(i_trade);    
    end
    if profitloss(i_trade) < 0 
        ltmfe(end+1) = mfe(i_trade);
        ltmfe_trade(end+1) = i_trade;
    end
end

mae = mae * unit ;
mfe = mfe * unit ;
profitloss = profitloss * unit ;
ltmfe = ltmfe * unit ;

f = figure; plot(mae,mfe,'kx');axis([0 scal 0 scal]);title('mae(x) vs. mfe(y) in pips');set(f, 'Position', [0, 0, 900, 450]);saveas(f,'mae_vs_mfe.png');
f = figure; plot(profitloss,mfe,'rx');axis([-scal scal 0 scal]);title('profit/loss(x) vs. mfe(y) in pips');set(f, 'Position', [0, 0, 900, 450]);saveas(f,'mae_vs_mfe.png');
f = figure; plot(profitloss,mae,'bx');axis([-scal scal 0 scal]);title('profit/loss(x) vs. mae(y) in pips');set(f, 'Position', [0, 0, 900, 450]);saveas(f,'mae_vs_mfe.png');
f = figure;hold on;plot([1:1:length(mfe)],mfe,'bo');plot(ltmfe_trade,ltmfe,'rx');hold off;axis([0.5 length(mfe)+0.5 0 scal]);title('mfe(blue) and ltmfe(red) in pips');set(f, 'Position', [0, 0, 900, 450]);saveas(f,'mfe_vs_ltmfe.png');

f = figure;subplot(2,1,1);plot(profitloss_cum,'k-');title('PnL');subplot(2,1,2);plot(mae,'r+');axis([-inf inf 0 scal]);title('mae');set(f, 'Position', [0, 0, 900, 450]);saveas(f,'mae_vs_PnL.png');
f = figure;subplot(2,1,1);plot(profitloss_cum,'k-');title('PnL');subplot(2,1,2);plot(mfe,'b+');axis([-inf inf 0 scal]);title('mfe');set(f, 'Position', [0, 0, 900, 450]);saveas(f,'mfe_vs_PnL.png');
f = figure;subplot(2,1,1);plot(profitloss_cum,'k-');title('PnL');subplot(2,1,2);plot(ltmfe_trade,ltmfe,'m+');axis([-inf inf 0 scal]);title('loss trade mfe');set(f, 'Position', [0, 0, 900, 450]);saveas(f,'ltmfe_vs_PnL.png');


    