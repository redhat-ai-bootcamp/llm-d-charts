# LLM-D Demo Helm Charts

Helm charts for demonstrating llm-d's intelligent routing vs vanilla vLLM, deployable via OpenShift click-ops.

## Quick Setup

### 1. Add the Helm Repository (via OpenShift Console)

1. Navigate to **Helm → Repositories** in the left sidebar
2. Click **Create → HelmChartRepository**
3. Select **Cluster scoped (HelmChartRepository)** to make charts available in all namespaces
4. Fill in:
   - **Name**: `llm-d-demo`
   - **Display name**: `LLM-D Demo Charts`
   - **URL**: `https://adam-d-young.github.io/llm-d-charts/`
5. Click **Create**

> **Alternative (CLI)**: `oc apply -f https://raw.githubusercontent.com/adam-d-young/llm-d-charts/main/helmchartrepository.yaml`

### 2. Create Required Namespaces

Before installing charts via click-ops, create the target namespaces:

```bash
oc create namespace llm-d-monitoring
oc create namespace demo-llm
```

| Chart | Target Namespace |
|-------|-----------------|
| `monitoring` | `llm-d-monitoring` |
| `vllm-baseline` | `demo-llm` |
| `llm-d` | `demo-llm` |
| `benchmark` | `demo-llm` |
| `llamastack-playground` | `demo-llm` |

> **Note**: CLI installation with `helm install --create-namespace` does not require pre-creating namespaces.

---

## Charts Included

| Chart | Description |
|-------|-------------|
| `monitoring` | Prometheus + Grafana with LLM performance dashboard |
| `vllm-baseline` | Vanilla vLLM deployment (4 replicas) for baseline comparison |
| `llm-d` | llm-d with intelligent prefix-aware routing |
| `benchmark` | Configurable benchmark job (target: vllm or llm-d) |
| `llamastack-playground` | Chat UI via Llama Stack (connects to vllm or llm-d) |

## Workshop Flow

### Step 1: Deploy Monitoring
Install the **monitoring** chart first to set up Prometheus and Grafana.

1. Create the namespace: `oc create namespace llm-d-monitoring`
2. Go to **Developer Console → +Add → Helm Chart**
3. Switch to project **llm-d-monitoring** in the project dropdown
4. Select **LLM-D Demo Charts → Llm D Monitoring**
5. Click **Install**
4. Once deployed, click the Grafana route and login with `admin` / `admin`
5. Navigate to **Dashboards → LLM Performance Dashboard**

### Step 2: Deploy vLLM Baseline
Install vanilla vLLM to establish baseline performance.

1. Create the namespace (if not done): `oc create namespace demo-llm`
2. Go to **Developer Console → +Add → Helm Chart**
3. Switch to project **demo-llm** in the project dropdown
4. Select **LLM-D Demo Charts → Vllm Baseline**
5. Configure replicas (default: 4)
6. Click **Install**
7. Wait for all pods to be ready

### Step 3: Run Benchmark Against vLLM
1. Go to **Developer Console → +Add → Helm Chart** (ensure **demo-llm** project is selected)
2. Select **LLM-D Demo Charts → Llm D Benchmark**
3. Set **Target** dropdown to `vllm`
4. Adjust duration and concurrency as desired
5. Click **Install**
6. Watch the Job logs in the console
7. Observe metrics in Grafana - note the P95/P99 latency and cache hit rate

### Step 4: Cleanup vLLM
1. Go to **Helm → Releases**
2. Uninstall the **benchmark** release
3. Uninstall the **vllm-baseline** release

### Step 5: Deploy llm-d
1. Go to **Developer Console → +Add → Helm Chart** (ensure **demo-llm** project is selected)
2. Select **LLM-D Demo Charts → Llm D**
3. Configure replicas (default: 2)
4. Click **Install**
5. Wait for all pods to be ready

### Step 6: Run Benchmark Against llm-d
1. Install the **Llm D Benchmark** chart again (in **demo-llm** project)
2. Set **Target** dropdown to `llm-d`
3. Click **Install**
4. Watch the Job logs
5. Compare Grafana metrics with vLLM baseline

### Step 7: (Optional) Deploy Chat UI
Install the Llama Stack Playground for interactive chat with your deployed model.

1. Ensure Llama Stack Operator is enabled (see Quick Setup step 2)
2. Go to **Developer Console → +Add → Helm Chart** (ensure **demo-llm** project is selected)
3. Select **LLM-D Demo Charts → Llamastack Playground**
4. Configure:
   - **Target Backend**: `llm-d` (or `vllm` if testing baseline)
   - **Provider Model ID**: Your model name (e.g., `Qwen/Qwen2.5-3B-Instruct`)
5. Click **Install**
6. Once deployed, click the **llamastack-playground** route to open the chat UI
7. Start chatting with your model!

## Expected Results

| Metric | vLLM (Round-Robin) | llm-d (Intelligent Routing) |
|--------|-------------------|----------------------------|
| P50 TTFT | ~123 ms | ~92 ms |
| P95 TTFT | ~745 ms | ~272 ms (**63% faster**) |
| P99 TTFT | ~841 ms | ~674 ms |
| Cache Speedup | 1.79x | 3.84x (**2.1x better**) |

## Key Takeaways

1. **Tail latency matters**: P95/P99 represents your most frustrated users
2. **Cache efficiency at scale**: Single-replica caching doesn't help when requests scatter across replicas
3. **Intelligent routing**: llm-d's prefix-aware routing ensures requests hit the replica with relevant cached data
4. **No application changes**: Same API, same model, better performance

## Hosting Charts (for developers)

To host these charts on GitHub Pages:

```bash
# Package charts
helm package charts/monitoring
helm package charts/vllm-baseline
helm package charts/llm-d
helm package charts/benchmark

# Generate index
helm repo index . --url https://your-org.github.io/llm-d-charts/

# Commit and push to gh-pages branch
```
