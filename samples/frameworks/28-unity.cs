using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Serialization;

namespace FrameworkTour.Unity
{
    /// <summary>
    /// Unity engine framework tour.
    /// </summary>
    /// <remarks>
    /// Covers MonoBehaviour lifecycle, serialized fields, coroutines,
    /// ScriptableObjects, events, physics callbacks and gizmos.
    /// </remarks>
    [RequireComponent(typeof(Rigidbody))]
    [AddComponentMenu("Gameplay/Player Controller")]
    public sealed class PlayerController : MonoBehaviour
    {
        [Header("Movement")]
        [SerializeField, Range(0f, 20f)] private float moveSpeed = 5f;
        [SerializeField, Tooltip("Upward force applied on jump.")] private float jumpForce = 7.5f;

        [Header("References")]
        [FormerlySerializedAs("cam")]
        [SerializeField] private Transform cameraTransform;
        [SerializeField] private LayerMask groundMask;

        [Space, SerializeField] private UnityEvent<int> onScoreChanged;

        private Rigidbody _rigidbody;
        private readonly List<Collider> _contacts = new();
        private int _score;
        private bool _isGrounded;

        /// <summary>Current score, clamped to zero.</summary>
        public int Score
        {
            get => _score;
            private set
            {
                _score = Mathf.Max(0, value);
                onScoreChanged?.Invoke(_score); // inline comment
            }
        }

        private void Awake() => _rigidbody = GetComponent<Rigidbody>();

        private void OnEnable() => Application.focusChanged += HandleFocusChanged;

        private void OnDisable() => Application.focusChanged -= HandleFocusChanged;

        private void Update()
        {
            var horizontal = Input.GetAxisRaw("Horizontal");
            var vertical = Input.GetAxisRaw("Vertical");
            var direction = new Vector3(horizontal, 0f, vertical).normalized;

            if (direction.sqrMagnitude > 0.01f)
            {
                transform.Translate(direction * (moveSpeed * Time.deltaTime), Space.World);
            }

            if (Input.GetButtonDown("Jump") && _isGrounded)
            {
                StartCoroutine(JumpRoutine());
            }
        }

        private void FixedUpdate()
        {
            _isGrounded = Physics.CheckSphere(transform.position, 0.2f, groundMask);
        }

        private IEnumerator JumpRoutine()
        {
            _rigidbody.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
            yield return new WaitForSeconds(0.1f);
            yield return new WaitUntil(() => _isGrounded);
            Score += 10;
        }

        private void OnCollisionEnter(Collision collision)
        {
            if (collision.gameObject.CompareTag("Pickup"))
            {
                Destroy(collision.gameObject);
                Score += 5;
            }
        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.cyan;
            Gizmos.DrawWireSphere(transform.position, 0.2f);
        }

        private void HandleFocusChanged(bool hasFocus) => Time.timeScale = hasFocus ? 1f : 0f;
    }

    /// <summary>A data container asset.</summary>
    [CreateAssetMenu(fileName = "LevelConfig", menuName = "Config/Level")]
    public sealed class LevelConfig : ScriptableObject
    {
        public string levelName = "Level 1";
        public int targetScore = 100;
        public AnimationCurve difficulty = AnimationCurve.Linear(0f, 0f, 1f, 1f);
    }
}
