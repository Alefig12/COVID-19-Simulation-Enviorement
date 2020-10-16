import controlP5.*;

private Graph graph;
private boolean startA = false;
private boolean step = false;
private int mode = 2;
private boolean started = true;
private boolean createdResume = false;
private int population = 5;
int contador = 0;
double inicio; 
ControlP5 cp5;

void setup(){
   size(1080,720);
   setGUI();
   surface.setTitle("COVID-19 Simulation");
}

void draw(){
    if(startA){
      if(!graph.isAllInfected()){
        if(System.currentTimeMillis() - inicio > 60000 || step){
          simulate();
          step = false;
        }
      }else{
        println("SE ACABO LA SIMULACION con " + contador + " iteraciones, todos se murieron");
        startA = false;
        started = true;
        createdResume = true;
     }    
    }
  }

public void setGUI(){
   noStroke();
   background(255,255,255);
   rectMode(CENTER);
   fill(0,0,0, 30);
   rect(920,130,260,210);
   fill(0,0,0, 30);
   rect(920,360,260,190);
   cp5  = new ControlP5(this);
   textSize(16);
   fill(0,0,0);
   text("Cantidad de personas",835,170);
   text("Uso de la mascarilla",840,70);
   text("FASE VISUAL EN PRUEBA, RESULTADOS EN CONSOLA",350,700);
   cp5.addSlider("peopleValues").setPosition(820,180).setSize(200,30).setValue(2).setRange(2,100).setNumberOfTickMarks(100).setSliderMode(Slider.FLEXIBLE);
   cp5.getController("peopleValues").setCaptionLabel("");
   cp5.addButton("inicia").setPosition(820,290).setSize(200,30);
   cp5.getController("inicia");
   cp5.getController("inicia").setCaptionLabel("Inicia la simulacion");
   cp5.addButton("Genera_Nuevo_Grafo").setPosition(820,330).setSize(200,30);
   cp5.getController("Genera_Nuevo_Grafo").setCaptionLabel("Genera un nuevo grafo aleatorio");
   cp5.addButton("Ver_Resumen").setPosition(820,370).setSize(200,30);
   cp5.getController("Ver_Resumen").setCaptionLabel("Generar sumario de la simulacion");
   cp5.addButton("Siguiente_Dia").setPosition(820,410).setSize(200,30);
   cp5.getController("Siguiente_Dia").setCaptionLabel("Avanzar al siguiente dia");
   cp5.addButton("Mascarilla").setPosition(800,90).setSize(75,30);
   cp5.getController("Mascarilla").setCaptionLabel("Obligatorio");   
   cp5.addButton("Sin_Mascarilla").setPosition(880,90).setSize(75,30);
   cp5.getController("Sin_Mascarilla").setCaptionLabel("Nadie");   
   cp5.addButton("Aleatorio").setPosition(960,90).setSize(75,30);
   cp5.getController("Aleatorio").setCaptionLabel("Uso aleatorio");   
}


public void buildIndex(){
  HTMLBuilder htmlB = new HTMLBuilder();
  htmlB.createTableHtml(graph.tablas);
  htmlB.seperateTagsTable(); //<>//
}

private void reload(int modo,int poblacion){
   graph = new Graph();
   graph.createNode(poblacion);
   graph = crearRanGrafo(graph);
   println("-----------------------DISPOSICION DE LA SIMULACION--------------------------------");
   for(NodoG g: graph.getNodes()){
     if(g.isInfected){
       println("INFECTADO|" + g.etiquetas);
     }
     for(Edge e: g.aristas){
       println("ORIGEN " + e.inicio.etiquetas + "| DESTINO " + e.destino.etiquetas + " CON UN PESO DE " + e.peso);
     }
   }
   println("---------------------------------------------------------------------------------------");
   graph.setMode(modo);
   graph.update();
   inicio = System.currentTimeMillis();
}

private void simulate(){
  saveFrame("/data/temp/Day"+contador+".png");
  contador += 1;
  avanzaGeneracion();
  graph.update(contador);
  println("REPORTE DEL MINISTERIO DE SALUD - DIA " + contador);
  println("SALUDABLES " + graph.getHealthy().size());
  graph.reporteMinisterioDeSalud(contador);
  println("--------------------------------------------------------------");
  inicio = System.currentTimeMillis();
}

public void Sin_Mascarilla(){
  mode = 1;
}

public void Aleatorio(){
  mode = 2;
}

public void Mascarilla(){
  mode = 0;
}
public void inicia(){
  println("ARRANCA");
  if(started){
    reload(mode,population);
    startA = true;  
    started = false;
    createdResume = false;
  }
}

public void peopleValues(int persona){
  population = persona;
}

public void Ver_Resumen(){
  if(createdResume){
    String path = dataPath("");
    buildIndex();
    println("Dirigite a " + path + "\\temp\\index.html, no borre la carpeta temp");
  }else{
    println("ARCHIVO NO GENERADO AUN");
  }
}

public void Genera_Nuevo_Grafo(){
  println("REINICIA");
  startA = false;
  started = true;
}

public void Siguiente_Dia(){
  if(startA){ 
    println("EL OTRO DIA...");
    step = true;
  }else{
    println("SIMULACION TERMINADA, POR FAVOR, CREE UN NUEVO GRAFO");
  }
}

private void avanzaGeneracion(){
  for(NodoG n: graph.infected){
    Infectado i = (Infectado) n;
    i.infecta();
  }
}

private Graph crearRanGrafo(Graph grafo){
  NodoG[] nodos = new NodoG[grafo.nodes.size()]; 
  nodos = grafo.convertArray();
  nodos = Shuffle.randomizeArray(nodos,grafo.nodes.size());
  for(int i = 0; i < nodos.length; i++){
    if(i + 1 != nodos.length){
      float peso = random(1,11);
      NodoG next = nodos[i+1];
      nodos[i].addEdge(new Edge(nodos[i],next,peso));
      nodos[i+1].addEdge(new Edge(next,nodos[i],peso));
    }
    int randomNumber = (int) random(0,nodos.length);
    int randomConexion = (int) random(0,2);
    while(randomNumber == i){
      randomNumber = (int) random(0,nodos.length);
    }
    if(randomConexion == 0){
      nodos[i].addEdge(new Edge(nodos[i],nodos[randomNumber],random(1,11)));
    }else{
      nodos[randomNumber].addEdge(new Edge(nodos[randomNumber],nodos[i],random(1,11)));
    }
  }
  graph.convertList(Shuffle.getOrdered((nodos)));
  return graph;
}
