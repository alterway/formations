import os, asyncio, httpx
from fastapi import FastAPI
from fastapi.responses import HTMLResponse

app = FastAPI()

# Liste des élèves configurée via variable d'environnement (ex: "alice,bob,charlie")
STUDENTS = os.getenv("STUDENTS", "eleve1,eleve2").split(",")
DOMAIN = os.getenv("DOMAIN", "apps.caas.fr")

statuses = {}

async def check_student(student: str):
    url = f"https://quartier-{student}.{DOMAIN}/health"
    async with httpx.AsyncClient(verify=False, timeout=2.0) as client:
        try:
            r = await client.get(url)
            if r.status_code == 200:
                data = r.json()
                statuses[student] = {"status": "OK", "pods": data.get("pods", 1), "latency": f"{r.elapsed.microseconds // 1000}ms"}
            else:
                statuses[student] = {"status": "ERROR", "pods": 0, "latency": "N/A"}
        except Exception:
            statuses[student] = {"status": "DOWN", "pods": 0, "latency": "N/A"}

async def poll_all():
    while True:
        tasks = [check_student(s) for s in STUDENTS]
        await asyncio.gather(*tasks)
        await asyncio.sleep(3)

@app.on_event("startup")
async def startup_event():
    asyncio.create_task(poll_all())

@app.get("/", response_class=HTMLResponse)
def get_grid():
    cards = ""
    for student, info in statuses.items():
        color = "#2ef072" if info["status"] == "OK" else ("#ff9900" if info["status"] == "ERROR" else "#ff4d4d")
        cards += f"""
        <div style="background:{color}; padding:20px; margin:10px; border-radius:8px; width:200px; text-align:center; font-family:sans-serif; color:black;">
            <h3>{student}</h3>
            <p><strong>Statut :</strong> {info['status']}</p>
            <p><strong>Pods :</strong> {info['pods']}</p>
            <p><strong>Latence :</strong> {info['latency']}</p>
        </div>
        """
    return f"""
    <html>
        <head><title>K8s War Room</title><meta http-equiv="refresh" content="3"></head>
        <body style="background:#121212; color:white; font-family:sans-serif; padding:20px;">
            <h1>Carte du Réseau K8s</h1>
            <div style="display:flex; flex-wrap:wrap;">{cards}</div>
        </body>
    </html>
    """
