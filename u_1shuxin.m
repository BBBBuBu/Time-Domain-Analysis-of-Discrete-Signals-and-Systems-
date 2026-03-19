clc
clear

% 低通滤波器，差分方程标准化：y[n] - 0.9y[n-1] = 0.05x[n] + 0.05x[n-1]
a = [1, -0.9];   % 输出端系数，对应y(n) -0.9y(n-1)
b = [0.05, 0.05];% 输入端系数，对应0.05x(n) + 0.05x(n-1)

% 生成时间序列与输入信号
n = 0:50;            % 足够长的时间范围，观察响应趋势
x1 = rect_seq(8, n); % 输入 x1[n] = R8[n]（8点矩形序列）
% x1 = [ones(1, 8), zeros(1, N-8)]
x2 = ones(1, length(n)); % 输入 x2[n] = u[n]（单位阶跃序列）

% 计算系统响应
y1 = filter(b, a, x1); % x1的系统响应
y2 = filter(b, a, x2); % x2的系统响应

% 计算单位脉冲响应
h= impz(b, a, length(n)); % 系统单位脉冲响应

% 绘制低通滤波器响应波形
figure('Name', '低通滤波器响应');
subplot(2,2,1);
stem(n, x1, 'b', 'MarkerSize', 4);%离散序列绘图函数，以n为时间轴、x1为信号值
title('输入信号 x₁[n] = R₅[n]');
xlabel('n'); ylabel('x₁[n]'); grid on;

subplot(2,2,2);
stem(n, y1, 'r', 'MarkerSize', 4);
title('x₁[n]的系统响应');
xlabel('n'); ylabel('y₁[n]'); grid on;

subplot(2,2,3);
stem(n, x2, 'b', 'MarkerSize', 4);
title('输入信号 x₂[n] = u[n]');
xlabel('n'); ylabel('x₂[n]'); grid on;

subplot(2,2,4);
stem(n, y2, 'r', 'MarkerSize', 4);
title('x₂[n]的系统响应');
xlabel('n'); ylabel('y₂[n]'); grid on;

% 绘制单位脉冲响应波形
figure('Name', '低通滤波器单位脉冲响应');
stem(n, h, 'm', 'MarkerSize', 4);
title('系统单位脉冲响应 h[n]');
xlabel('n'); ylabel('h[n]'); grid on;

% 2线性卷积：系统 h₁[n] = R₁₀[n]、h₂[n] = δ[n]+2.5δ[n-2]+δ[n-3]
n_conv = 0:20;       % 时间序列，覆盖卷积结果长度
x_conv = rect_seq(8, n_conv); % 输入 x[n] = R₅[n]

% 定义系统单位脉冲响应
h1_conv = rect_seq(10, n_conv); % h₁[n] = R₁₀[n]（10点矩形序列）
h2_conv = zeros(1, length(n_conv)); % h₂[n]初始化
h2_conv(n_conv == 0) = 1;     % δ[n]分量
h2_conv(n_conv == 2) = 2.5;   % 2.5δ[n-2]分量
h2_conv(n_conv == 3) = 1;     % δ[n-3]分量

% 线性卷积计算输出
y_conv1 = conv(x_conv, h1_conv); % x与h₁的卷积
y_conv2 = conv(x_conv, h2_conv); % x与h₂的卷积

% 卷积结果的时间序列
n_y1 = 0:(length(x_conv)+length(h1_conv)-2);
n_y2 = 0:(length(x_conv)+length(h2_conv)-2);

% 绘制线性卷积输出波形
figure('Name', '线性卷积输出');
subplot(2,1,1);
stem(n_conv, x_conv, 'b', 'MarkerSize', 4, 'DisplayName', 'x[n]'); hold on;
stem(n_conv, h1_conv, 'g', 'MarkerSize', 4, 'DisplayName', 'h₁[n]');
stem(n_y1, y_conv1, 'r', 'MarkerSize', 4, 'DisplayName', 'y₁[n] = x[n] * h₁[n]');
title('x[n]与h₁[n]的线性卷积');
xlabel('n'); ylabel('幅值'); grid on; legend; hold off;

subplot(2,1,2);
stem(n_conv, x_conv, 'b', 'MarkerSize', 4, 'DisplayName', 'x[n]'); hold on;
stem(n_conv, h2_conv, 'g', 'MarkerSize', 4, 'DisplayName', 'h₂[n]');
stem(n_y2, y_conv2, 'r', 'MarkerSize', 4, 'DisplayName', 'y₂[n] = x[n] * h₂[n]');
title('x[n]与h₂[n]的线性卷积');
xlabel('n'); ylabel('幅值'); grid on; legend; hold off;

% 谐振器：
% 差分方程标准化 y[n]-1.8237y[n-1]+0.9801y[n-2]=b₀x[n] - b₀x[n-2]（b₀=1/100.49）
b0 = 1 / 100.49;
a_res = [1, -1.8237, 0.9801]; % 输出端系数（y[n], y[n-1], y[n-2]）
b_res = [b0, 0, -b0];         % 输入端系数（x[n], x[n-1], x[n-2]）

% 输入u[n]检验稳定性
n_res = 0:100;
x_u = ones(1, length(n_res)); % 输入 x[n] = u[n]（单位阶跃）
y_u = filter(b_res, a_res, x_u); % 系统输出.

% ② 输入x[n] = sin(0.014n) + sin(0.4n)
x_sin = sin(0.014 * n_res) + sin(0.4 * n_res); % 混合正弦输入
y_sin = filter(b_res, a_res, x_sin);          % 系统输出

% 绘制谐振器波形
figure('Name', '谐振器特性');
subplot(2,1,1);
stem(n_res, y_u, 'b', 'MarkerSize', 4);
title('输入u[n]的系统输出（稳定性检验）');
xlabel('n'); ylabel('y[n]'); grid on;

subplot(2,1,2);
stem(n_res, x_sin, 'b', 'MarkerSize', 4, 'DisplayName', '输入x[n]'); hold on;
stem(n_res, y_sin, 'r', 'MarkerSize', 4, 'DisplayName', '输出y[n]');
title('输入x[n] = sin(0.014n) + sin(0.4n)的系统输出');
xlabel('n'); ylabel('幅值'); grid on; legend; hold off;

% 辅助函数：生成N点矩形序列 R_N[n]（n∈[0,N-1]时为1，否则为0）
function x = rect_seq(N, n)
    x = (n >= 0) & (n < N); % 逻辑判断：0≤n<N时为true，否则为false
    x = double(x);          % 转换为数值（true→1，false→0）
end
