import numpy as np

# 1. 准备输入数据和偏置 (Amend Table 1 by adding the bias) 
# 输入数据 x1, x2 [cite: 3]
X = np.array([
    [0.1, 0.75],
    [0.4, 0.6],
    [0.75, 0.6],
    [0.15, 0.25],
    [0.2, 0.4],
    [0.6, 0.35]
])

# 添加偏置项 x0 = 1，使得每个样本变为 (1, x1, x2)
bias = np.ones((X.shape[0], 1))
X_amended = np.hstack((bias, X))

# ⚠️ 请根据 Fig. 1 替换这里的标签 d 
# 假设 Class A 为 1, Class B 为 0。你需要对照图片中圆圈和方块(或其他标记)属于哪一类。
d = np.array([1, 1, 0, 1, 0, 0]) # 占位符标签

# 2. 初始化参数 
# 初始权重 W(0) = (-0.1, 1.0, -0.4) 
W = np.array([-0.1, 1.0, -0.4])
eta = 0.2  # 学习率 

# 3. 定义 Heaviside Step 激活函数 
def heaviside_step(net):
    return 1 if net >= 0 else 0

# 4. 执行 One Epoch (Fixed-Increment Learning Algorithm) [cite: 7, 8]
print("Starting weights:", W)
print("-" * 30)

for i in range(len(X_amended)):
    x_i = X_amended[i]
    target = d[i]
    
    # 计算加权和 (net)
    net = np.dot(W, x_i)
    
    # 计算输出 y
    y = heaviside_step(net)
    
    # 更新权重 W(t+1) = W(t) + eta * (d - y) * x
    if target != y:
        W = W + eta * (target - y) * x_i
        print(f"Sample {i+1} misclassified. Target: {target}, Output: {y}")
        print(f"Updated Weights: {np.round(W, 3)}")
    else:
        print(f"Sample {i+1} correctly classified.")

print("-" * 30)
print("Final weights after 1 epoch:", np.round(W, 3))
# 提示: 检查最终权重是否接近文档给出的提示 (-0.1, 0.95, -0.47) 或 (-0.1, 0.79, -0.36)