#include <ruby.h>
#include <math.h>

#define FUNDAMENTAL_HZ 12.0
#define TOLERANCE 0.6 // 5% of 12Hz

VALUE method_analyze_frequencies(VALUE self, VALUE rb_magnitudes) {
    Check_Type(rb_magnitudes, T_ARRAY);

    long len = RARRAY_LEN(rb_magnitudes);
    long limit = (len < 100) ? len : 100;

    int anomaly_hz = -1;
    const char *status = "healthy";

    for (long hz = 1; hz < limit; hz++) {
        VALUE rb_val = rb_ary_entry(rb_magnitudes, hz);
        if (NIL_P(rb_val)) continue;

        int magnitude = NUM2INT(rb_val);

        if (magnitude >= 100) {
            double remainder = fmod((double)hz, FUNDAMENTAL_HZ);
            int is_harmonic = (remainder <= TOLERANCE) || ((FUNDAMENTAL_HZ - remainder) <= TOLERANCE);

            if (!is_harmonic) {
                status = "critical_anomaly";
                anomaly_hz = (int)hz;
                break;
            }
        }
    }

    VALUE rb_result = rb_hash_new();
    rb_hash_aset(rb_result, ID2SYM(rb_intern("status")), rb_str_new2(status));
    rb_hash_aset(rb_result, ID2SYM(rb_intern("flagged_hz")), (anomaly_hz == -1) ? Qnil : INT2NUM(anomaly_hz));

    return rb_result;
}

void Init_dsp_analyzer(void) {
    VALUE mDspAnalyzer = rb_define_module("DspAnalyzer");
    rb_define_module_function(mDspAnalyzer, "analyze", method_analyze_frequencies, 1);
}
