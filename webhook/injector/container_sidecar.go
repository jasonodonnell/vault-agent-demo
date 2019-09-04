package injector

import (
	"errors"
	corev1 "k8s.io/api/core/v1"
	"strings"
)

func (h *Handler) containerServiceAccount(pod *corev1.Pod) (string, string) {
	for _, container := range pod.Spec.Containers {
		for _, volumes := range container.VolumeMounts {
			if strings.Contains(volumes.MountPath, "serviceaccount") {
				return volumes.Name, volumes.MountPath
			}
		}
	}
	return "", ""
}

func (h *Handler) containerSidecar(pod *corev1.Pod) (corev1.Container, error) {
	serviceAccountName, serviceAccountPath := h.containerServiceAccount(pod)
	if serviceAccountName == "" || serviceAccountPath == "" {
		return corev1.Container{}, errors.New("no service account found on pod")
	}

	return corev1.Container{
		Name:  "vault-agent",
		Image: h.ImageAgent,
		Env:   h.containerEnvVars(pod),
		VolumeMounts: []corev1.VolumeMount{
			{
				Name:      "vault-secrets",
				MountPath: "/vault/secrets",
				ReadOnly:  false,
			},
			{
				Name:      serviceAccountName,
				MountPath: serviceAccountPath,
				ReadOnly:  true,
			},
		},
	}, nil
}
