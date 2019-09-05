package injector

import (
	"fmt"
	corev1 "k8s.io/api/core/v1"
	"strings"
)

func (h *Handler) secretAnnotations(pod *corev1.Pod) []corev1.EnvVar {
	var envs []corev1.EnvVar
	for name, value := range pod.Annotations {
		if strings.Contains(name, "agent-inject-secret") {
			annotation := strings.Replace(
				strings.ToUpper(strings.Trim(name, "vault.hashicorp.com/agent-inject-secret-")),
				"-", "_", -1,
			)

			envs = append(envs, corev1.EnvVar{
				Name:  fmt.Sprintf("VAULT_SECRET_%s", annotation),
				Value: value,
			})
		}
	}
	return envs
}

func (h *Handler) serviceAnnotation(pod *corev1.Pod) corev1.EnvVar {
	raw, ok := pod.Annotations[annotationService]
	if !ok || raw == "" {
		return corev1.EnvVar{}
	}

	return corev1.EnvVar{
		Name:  "VAULT_ADDR",
		Value: raw,
	}
}

func (h *Handler) containerEnvVars(pod *corev1.Pod) []corev1.EnvVar {
	if len(pod.Annotations) < 1 {
		h.Log.Info("No annotations, skipping..")
		return []corev1.EnvVar{}
	}

	var result []corev1.EnvVar
	result = h.secretAnnotations(pod)
	result = append(result, h.serviceAnnotation(pod))

	result = append(result, corev1.EnvVar{
		Name: "HOST_IP",
		ValueFrom: &corev1.EnvVarSource{
			FieldRef: &corev1.ObjectFieldSelector{FieldPath: "status.hostIP"},
		},
	})

	return result
}
