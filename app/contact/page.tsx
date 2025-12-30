export const metadata = {
  title: 'Contact Us - TamiGoods',
  description: 'Get in touch with TamiGoods',
}

export default function Contact() {
  return (
    <div className="bg-gray-50 min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-primary-600 via-primary-500 to-primary-700 text-white py-16 px-4">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl md:text-6xl font-bold mb-4">
            Contact Us
          </h1>
          <p className="text-xl text-primary-100">
            We'd love to hear from you
          </p>
        </div>
      </section>

      {/* Main Content */}
      <section className="py-16 px-4">
        <div className="max-w-4xl mx-auto">
          <div className="bg-white rounded-xl shadow-lg p-8 md:p-12">
            <div className="text-center mb-12">
              <h2 className="text-3xl font-bold text-gray-900 mb-4">
                Get in Touch
              </h2>
              <p className="text-lg text-gray-700">
                Have a question or want to learn more about TamiGoods? 
                Feel free to reach out to us using the contact information below.
              </p>
            </div>

            <div className="space-y-8">
              {/* Email Section */}
              <div className="bg-primary-50 rounded-lg p-8 text-center">
                <div className="w-16 h-16 bg-primary-600 rounded-full flex items-center justify-center mx-auto mb-4">
                  <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                  </svg>
                </div>
                <h3 className="text-xl font-bold text-gray-900 mb-2">Email Us</h3>
                <a 
                  href="mailto:info@tamigoods.eu" 
                  className="text-primary-600 hover:text-primary-700 text-lg font-medium transition-colors"
                >
                  info@tamigoods.eu
                </a>
              </div>

              {/* Additional Info */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
                <div className="p-6 bg-gray-50 rounded-lg">
                  <h3 className="font-bold text-gray-900 mb-2">Business Hours</h3>
                  <p className="text-gray-700">
                    Monday - Friday: 9:00 AM - 6:00 PM<br />
                    Saturday: 10:00 AM - 4:00 PM<br />
                    Sunday: Closed
                  </p>
                </div>
                <div className="p-6 bg-gray-50 rounded-lg">
                  <h3 className="font-bold text-gray-900 mb-2">Response Time</h3>
                  <p className="text-gray-700">
                    We typically respond to all inquiries within 24-48 hours during business days.
                  </p>
                </div>
              </div>

              {/* Coming Soon Notice */}
              <div className="mt-8 p-6 bg-primary-100 rounded-lg border-l-4 border-primary-600">
                <p className="text-gray-700">
                  <strong>Note:</strong> We're currently in the preparation phase. 
                  While we're not yet open for business, we're happy to answer any questions 
                  you may have about our upcoming launch.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}

