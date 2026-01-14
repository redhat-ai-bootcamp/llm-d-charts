# LLM-D Demo Helm Charts

Helm charts for demonstrating llm-d's intelligent routing vs vanilla vLLM, deployable via OpenShift click-ops.

## Charts Included

| Chart | Description |
|-------|-------------|
| `monitoring` | Prometheus + Grafana with LLM performance dashboard |
| `vllm-baseline` | Vanilla vLLM deployment (4 replicas) for baseline comparison |
| `llm-d` | llm-d with intelligent prefix-aware routing |
| `benchmark` | Configurable benchmark job (target: vllm or llm-d) |

## Prerequisites for Click-Ops Deployment

**Important**: Before installing charts via the OpenShift Developer Console (click-ops), you must create the target namespaces first. The console requires the namespace to exist to track Helm release status.

```bash
# Create required namespaces
oc create namespace llm-d-monitoring
oc create namespace demo-llm
```

| Chart | Target Namespace |
|-------|-----------------|
| `monitoring` | `llm-d-monitoring` |
| `vllm-baseline` | `demo-llm` |
| `llm-d` | `demo-llm` |
| `benchmark` | `demo-llm` |

> **Note**: CLI installation with `helm install --create-namespace` does not require pre-creating namespaces.

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

## Registering Charts in OpenShift

Apply the HelmChartRepository to make these charts available in the OpenShift Developer Console:

```bash
oc apply -f helmchartrepository.yaml
```

## Hosting Charts

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
