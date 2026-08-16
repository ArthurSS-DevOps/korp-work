package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	requestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_server_requests_total",
			Help: "Total de requisicoes recebidas pelo servidor.",
		},
		[]string{"method", "endpoint", "status"},
	)

	serviceUp = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Name: "http_server_up",
			Help: "Disponibilidade do servico HTTP. 1 = disponivel, 0 = indisponivel.",
		},
	)
)

func init() {
	prometheus.MustRegister(requestsTotal)
	prometheus.MustRegister(serviceUp)

	serviceUp.Set(1)
}

func projetoKorpHandler(w http.ResponseWriter, r *http.Request) {
	start := time.Now()

	response := map[string]string{
		"nome":    "Projeto Korp",
		"horario": time.Now().UTC().Format(time.RFC3339),
	}

	w.Header().Set("Content-Type", "application/json")

	status := http.StatusOK

	if err := json.NewEncoder(w).Encode(response); err != nil {
		status = http.StatusInternalServerError
	}

	requestsTotal.WithLabelValues(
		r.Method,
		"/projeto-korp",
		fmt.Sprintf("%d", status),
	).Inc()

	log.Printf(
		"method=%s endpoint=%s status=%d duration=%s",
		r.Method,
		"/projeto-korp",
		status,
		time.Since(start),
	)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	response := map[string]string{
		"status": "healthy",
	}

	_ = json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/projeto-korp", projetoKorpHandler)
	http.HandleFunc("/health", healthHandler)

	http.Handle("/metrics", promhttp.Handler())

	log.Println("http-server-projeto-korp iniciado na porta 8080")

	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}
