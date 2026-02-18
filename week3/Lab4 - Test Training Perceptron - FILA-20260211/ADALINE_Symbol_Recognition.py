import numpy as np

# 1. 定义 3x3 符号图案 (基于双极性表示 1 和 -1) [cite: 11, 12, 13]
# ⚠️ 请根据 Fig. 2 的实际图案修改以下数组。这里以字母 'T' 和 'L' 为例。
symbol_A = np.array([
    1,  1,  1,
   -1,  1, -1,
   -1,  1, -1
]) # 类别 1

symbol_B = np.array([
    1, -1, -1,
    1, -1, -1,
    1,  1,  1
]) # 类别 -1

# 训练集和标签
X_train = np.array([symbol_A, symbol_B])
d_train = np.array([1, -1])

# 添加偏置项
bias = np.ones((X_train.shape[0], 1))
X_train_amended = np.hstack((bias, X_train))

# 2. ADALINE 参数初始化 [cite: 14]
# 9个输入节点 + 1个偏置节点 = 10个权重
W_adaline = np.random.uniform(-0.1, 0.1, 10) 
eta_adaline = 0.05
epochs = 50

# 3. 训练 ADALINE (Widrow-Hoff 规则 / Delta Rule)
for epoch in range(epochs):
    for i in range(len(X_train_amended)):
        x_i = X_train_amended[i]
        target = d_train[i]
        
        # ADALINE 的误差计算使用线性加权和 (不经过激活函数)
        net = np.dot(W_adaline, x_i)
        error = target - net
        
        # 更新权重: W = W + eta * error * x
        W_adaline = W_adaline + eta_adaline * error * x_i

print("Trained ADALINE Weights:", np.round(W_adaline, 3))

# 4. 测试: 带有一个损坏位 (corrupted bit) 的符号 
# 将 symbol_A 的第一个位反转 (从 1 变成 -1)
corrupted_symbol = symbol_A.copy()
corrupted_symbol[0] = -1 
x_corrupted = np.insert(corrupted_symbol, 0, 1) # 加入偏置

# 计算最大和最小加权和 (net) 以及受损符号的 net 
net_A = np.dot(W_adaline, X_train_amended[0])
net_B = np.dot(W_adaline, X_train_amended[1])
net_corrupted = np.dot(W_adaline, x_corrupted)

print("-" * 30)
print(f"Net for Symbol A (Clean): {net_A:.3f}")
print(f"Net for Symbol B (Clean): {net_B:.3f}")
print(f"Net for Corrupted Symbol A: {net_corrupted:.3f}")

# 5. 关于阈值调整 (Threshold adjustment) 的分析提示 
print("\n--- 阈值分析 (Threshold Analysis) ---")
print("在标准ADALINE中，通常使用 0 作为分类阈值 (net >= 0 为类别1)。")
print(f"你可以观察到受损图案的 net 值为 {net_corrupted:.3f}。")
print("只要受损图案的 net 仍然处于正确的阈值一侧（比如 > 0），它就能被正确分类。")
print("调整偏置权重（Bias weight）可以平移整体的 net 值，从而改变决策边界（阈值）。")